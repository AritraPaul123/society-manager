import 'package:flutter/material.dart';
import 'package:society_man/core/services/qr_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'dart:io';

class EnhancedPatrolScreen extends StatefulWidget {
  final String guardId;

  const EnhancedPatrolScreen({super.key, required this.guardId});

  @override
  State<EnhancedPatrolScreen> createState() => _EnhancedPatrolScreenState();
}

class _EnhancedPatrolScreenState extends State<EnhancedPatrolScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _checkpointPhoto;
  bool _isOnline = true;
  bool _isOfflineMode = false;
  bool _isSyncing = false;
  bool _isPaused = false;
  late PatrolSession _patrolSession;
  late Stream<List<ConnectivityResult>> _connectivityStream;

  final List<PatrolCheckpoint> _checkpoints = [
    PatrolCheckpoint(
      id: 'cp001',
      name: "Main Entrance Gate",
      qrCode: "QR001",
      sequenceNumber: 1,
    ),
    PatrolCheckpoint(
      id: 'cp002',
      name: "Parking Lot A",
      qrCode: "QR002",
      sequenceNumber: 2,
    ),
    PatrolCheckpoint(
      id: 'cp003',
      name: "East Wing Corridor",
      qrCode: "QR003",
      sequenceNumber: 3,
    ),
    PatrolCheckpoint(
      id: 'cp004',
      name: "Basement Gate",
      qrCode: "QR004",
      sequenceNumber: 4,
    ),
    PatrolCheckpoint(
      id: 'cp005',
      name: "Server Room Access",
      qrCode: "QR005",
      sequenceNumber: 5,
    ),
    PatrolCheckpoint(
      id: 'cp006',
      name: "Rooftop Access",
      qrCode: "QR006",
      sequenceNumber: 6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializePatrolSession();
    _initializeConnectivityListener();
  }

  void _initializePatrolSession() {
    _patrolSession = PatrolSession(
      id: 'patrol_${DateTime.now().millisecondsSinceEpoch}',
      guardId: widget.guardId,
      startTime: DateTime.now(),
      checkpoints: _checkpoints,
      isPaused: false,
      isOffline: false,
      currentCheckpointIndex: 0,
      incidents: [],
    );
  }

  void _initializeConnectivityListener() {
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          // Use the first result or check if any connection is available
          ConnectivityResult result = results.isNotEmpty
              ? results.first
              : ConnectivityResult.none;
          _isOnline = result != ConnectivityResult.none;

          // Handle connectivity changes
          if (_isOnline && _isOfflineMode) {
            _handleOnlineReconnection();
          } else if (!_isOnline && !_isOfflineMode) {
            _handleOfflineMode();
          }
        });
      }
    });
  }

  void _handleOnlineReconnection() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Sync pending patrol data
      final pendingData = await LocalStorageService.getPendingPatrolData();
      // In a real app, you would send this data to your backend

      // Clear pending data after sync
      await LocalStorageService.clearPendingPatrolData();

      // Update patrol session
      _patrolSession.isOffline = false;
      await LocalStorageService.saveActivePatrol(_patrolSession);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _isOfflineMode = false;
        });
      }
    }
  }

  void _handleOfflineMode() {
    setState(() {
      _isOfflineMode = true;
      _patrolSession.isOffline = true;
    });

    // Save patrol session locally
    LocalStorageService.saveActivePatrol(_patrolSession);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline mode enabled - Data will be saved locally'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleQRScan() async {
    final String? qrData = await QRScannerService.scanQRCode(context);
    if (qrData != null && mounted) {
      final currentCheckpoint = _getCurrentCheckpoint();

      // Verify QR code matches current checkpoint
      if (qrData == currentCheckpoint.qrCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code verified!'),
            backgroundColor: Colors.green,
          ),
        );

        // Prompt for photo verification
        await _takeCheckpointPhoto();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR Code for this checkpoint!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takeCheckpointPhoto() async {
    // Only allow camera source, no gallery option (anti-cheat)
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      final photoFile = File(photo.path);

      setState(() {
        _checkpointPhoto = photoFile;
      });

      // Mark checkpoint as completed
      final currentCheckpoint = _getCurrentCheckpoint();
      currentCheckpoint.isCompleted = true;
      currentCheckpoint.completedAt = DateTime.now();
      currentCheckpoint.photo = photoFile;

      // Move to next checkpoint
      if (_patrolSession.currentCheckpointIndex < _checkpoints.length - 1) {
        _patrolSession.currentCheckpointIndex++;
      }

      // Save patrol data
      await LocalStorageService.saveActivePatrol(_patrolSession);

      // If offline, save pending data
      if (_isOfflineMode) {
        final pendingData = {
          'checkpointId': currentCheckpoint.id,
          'timestamp': DateTime.now().toIso8601String(),
          'photoPath': photo.path,
          'guardId': widget.guardId,
          'patrolId': _patrolSession.id,
        };

        await LocalStorageService.savePendingPatrolData(pendingData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkpoint verified with live photo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _reportIncident() async {
    // In a real app, you would show a dialog to enter incident details
    // For now, we'll just create a sample incident

    final incident = {
      'id': 'incident_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
      'guardId': widget.guardId,
      'patrolId': _patrolSession.id,
      'checkpointId': _getCurrentCheckpoint().id,
      'description': 'Sample incident reported',
    };

    // Add to patrol session incidents
    _patrolSession.incidents.add(incident);

    // Save patrol data
    await LocalStorageService.saveActivePatrol(_patrolSession);

    // If offline, save pending data
    if (_isOfflineMode) {
      await LocalStorageService.savePendingPatrolData(incident);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident reported successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _pausePatrol() async {
    setState(() {
      _isPaused = true;
      _patrolSession.isPaused = true;
    });

    // Save patrol session
    await LocalStorageService.saveActivePatrol(_patrolSession);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patrol paused'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _resumePatrol() async {
    setState(() {
      _isPaused = false;
      _patrolSession.isPaused = false;
    });

    // Save patrol session
    await LocalStorageService.saveActivePatrol(_patrolSession);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patrol resumed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _endPatrol() async {
    _patrolSession.endTime = DateTime.now();

    // Save patrol session
    await LocalStorageService.saveActivePatrol(null); // Clear active patrol

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patrol completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.attendanceManagement,
        (route) => false,
      );
    }
  }

  PatrolCheckpoint _getCurrentCheckpoint() {
    return _checkpoints[_patrolSession.currentCheckpointIndex];
  }

  double get _progress {
    int completed = _checkpoints.where((cp) => cp.isCompleted).length;
    return completed / _checkpoints.length;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildHeader()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 361),
                  child: Column(
                    children: [
                      _buildConnectionStatusCard(),
                      const SizedBox(height: 16),
                      _buildPatrolProgressCard(),
                      const SizedBox(height: 24),
                      _buildQRCheckpointCard(),
                      const SizedBox(height: 24),
                      _buildAllCheckpointsList(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Image.asset('assets/icons/app_logo.jpg', fit: BoxFit.contain),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guard Patrol System',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                letterSpacing: -0.2,
                height: 1.5,
              ),
            ),
            Text(
              'Field Operations Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF7B7A80),
                letterSpacing: -0.2,
                height: 1.43,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectionStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: _isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOnline ? const Color(0xFFA5D6A7) : const Color(0xFFFFE082),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            color: _isOnline
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFFC107),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'Online' : 'Offline Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isOnline
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFFF8F00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnline
                      ? 'Connected to server'
                      : 'Data saved locally, will sync when online',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7B7A80),
                  ),
                ),
              ],
            ),
          ),
          if (_isSyncing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8063FC)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPatrolProgressCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Patrol Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Patrol',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF7B7A80),
                  letterSpacing: -0.2,
                  height: 1.43,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Building A - Night Patrol',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  letterSpacing: -0.2,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Overall Progress
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF7B7A80),
                      letterSpacing: -0.2,
                      height: 1.43,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF8063FC),
                      letterSpacing: -0.2,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFEFF2F3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8063FC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Current Checkpoint
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Checkpoint',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF7B7A80),
                    letterSpacing: -0.2,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Checkpoint ${_patrolSession.currentCheckpointIndex + 1}: ${_getCurrentCheckpoint().name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    letterSpacing: -0.2,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Completed/Remaining Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E5F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        '${_checkpoints.where((cp) => cp.isCompleted).length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF8063FC),
                          height: 1.33,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF7B7A80),
                          letterSpacing: -0.2,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        '${_checkpoints.length - _checkpoints.where((cp) => cp.isCompleted).length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          height: 1.33,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Remaining',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF7B7A80),
                          letterSpacing: -0.2,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCheckpointCard() {
    final currentCheckpoint = _getCurrentCheckpoint();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Column(
            children: [
              Text(
                'Next Checkpoint',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -0.2,
                  height: 1.56,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Scan QR code to verify location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF7B7A80),
                  letterSpacing: -0.2,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // QR Code Button
          GestureDetector(
            onTap: _isPaused ? null : _handleQRScan,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8063FC), Color(0xFF6F52E8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8063FC).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      letterSpacing: -0.2,
                      height: 1.56,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Next Steps
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Steps:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    letterSpacing: -0.2,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNextStepItem('Scan checkpoint QR code'),
                _buildNextStepItem('Take live verification photo'),
                _buildNextStepItem('Confirm and continue to next checkpoint'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF7B7A80),
          letterSpacing: -0.2,
          height: 1.43,
        ),
      ),
    );
  }

  Widget _buildAllCheckpointsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Checkpoints',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              letterSpacing: -0.2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _checkpoints.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final checkpoint = _checkpoints[index];
              final isCurrentCheckpoint =
                  index == _patrolSession.currentCheckpointIndex;
              final isCompleted = checkpoint.isCompleted;

              return Container(
                decoration: BoxDecoration(
                  color: isCurrentCheckpoint
                      ? const Color(0xFFF4F5FA)
                      : (isCompleted
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFEFF2F3)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentCheckpoint
                        ? const Color(0xFF8063FC)
                        : (isCompleted
                              ? const Color(0xFFA5D6A7)
                              : const Color(0xFFE5E7EB)),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrentCheckpoint
                            ? const Color(0xFF8063FC).withOpacity(0.1)
                            : (isCompleted
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : const Color(0xFFE5E7EB)),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : Icons.location_on_outlined,
                          size: 16,
                          color: isCurrentCheckpoint
                              ? const Color(0xFF8063FC)
                              : (isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF7B7A80)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        checkpoint.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          letterSpacing: -0.2,
                          height: 1.43,
                        ),
                      ),
                    ),
                    if (isCompleted && checkpoint.completedAt != null)
                      Text(
                        '${checkpoint.completedAt!.hour}:${checkpoint.completedAt!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B7A80),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isPaused ? _resumePatrol : _pausePatrol,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isPaused ? 'Resume' : 'Pause',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _reportIncident,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7000B),
                  side: const BorderSide(color: const Color(0xFFFFC9C9)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // End Patrol Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _progress == 1.0 ? _endPatrol : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _progress == 1.0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFBDBDBD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              _progress == 1.0 ? 'End Patrol' : 'Complete All Checkpoints',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
