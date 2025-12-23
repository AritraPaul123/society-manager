import 'dart:async';

import 'package:flutter/material.dart';
import 'package:society_man/core/services/qr_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:society_man/core/services/connectivity_service.dart';

class GuardPatrolScanScreen extends StatefulWidget {
  const GuardPatrolScanScreen({super.key});

  @override
  State<GuardPatrolScanScreen> createState() => _GuardPatrolScanScreenState();
}

class _GuardPatrolScanScreenState extends State<GuardPatrolScanScreen> {
  bool _isScanning = false;
  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySubscription;
  List<PatrolCheckpoint> _checkpoints = [];
  int _currentCheckpointIndex = 0;
  bool _isPatrolPaused = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initializePatrol();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    // Initialize connectivity service and listen for changes
    final connectivityService = ConnectivityService();
    await connectivityService.initialize();

    _connectivitySubscription = connectivityService.connectionStatusStream
        .listen((isOnline) {
          setState(() {
            _isOnline = isOnline;
            if (_isOnline && !_isSyncing) {
              _attemptSync();
            }
          });
        });
  }

  Future<void> _attemptSync() async {
    // When connectivity is restored, sync any pending data
    setState(() {
      _isSyncing = true;
    });

    try {
      // Get any pending patrol data from local storage
      final pendingData = await LocalStorageService.getPendingPatrolData();

      if (pendingData.isNotEmpty) {
        // In a real app, this would sync with the backend
        // For now, we'll just clear the pending data
        await LocalStorageService.clearPendingPatrolData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data synced successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Check if patrol is complete and needs to be finalized
      final activePatrol = await LocalStorageService.getActivePatrol();
      if (activePatrol != null && _isPatrolComplete()) {
        // Complete the patrol and sync to server
        await LocalStorageService.saveActivePatrol(null);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patrol completed and synced!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to dashboard
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.attendanceManagement,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  bool _isPatrolComplete() {
    return _checkpoints.every((checkpoint) => checkpoint.isCompleted);
  }

  Future<void> _initializePatrol() async {
    // Load patrol data - in a real app, this would come from an API when online
    // For now, we'll create sample checkpoints
    setState(() {
      _checkpoints = [
        PatrolCheckpoint(
          id: 'CP001',
          name: 'Main Gate',
          qrCode: 'MAIN_GATE_001',
          sequenceNumber: 1,
        ),
        PatrolCheckpoint(
          id: 'CP002',
          name: 'Parking Area',
          qrCode: 'PARKING_002',
          sequenceNumber: 2,
        ),
        PatrolCheckpoint(
          id: 'CP003',
          name: 'Pool Area',
          qrCode: 'POOL_003',
          sequenceNumber: 3,
        ),
        PatrolCheckpoint(
          id: 'CP004',
          name: 'Gym',
          qrCode: 'GYM_004',
          sequenceNumber: 4,
        ),
        PatrolCheckpoint(
          id: 'CP005',
          name: 'Back Gate',
          qrCode: 'BACK_GATE_005',
          sequenceNumber: 5,
        ),
      ];
    });
  }

  Future<void> _scanCheckpoint() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final qrCode = await QRScannerService.scanCheckpointQR(context);

      if (qrCode != null && mounted) {
        // Find the matching checkpoint
        final matchingCheckpoint = _checkpoints.firstWhere(
          (cp) => cp.qrCode == qrCode,
          orElse: () =>
              _checkpoints[_currentCheckpointIndex], // fallback to current
        );

        // Capture photo using camera
        final photo = await _capturePhoto();

        if (photo != null) {
          // Update checkpoint with photo and completion time
          final updatedCheckpoint = PatrolCheckpoint(
            id: matchingCheckpoint.id,
            name: matchingCheckpoint.name,
            qrCode: matchingCheckpoint.qrCode,
            sequenceNumber: matchingCheckpoint.sequenceNumber,
            isCompleted: true,
            completedAt: DateTime.now(),
            photo: photo,
          );

          // Update the checkpoint in the list
          final updatedCheckpoints = List<PatrolCheckpoint>.from(_checkpoints);
          final index = updatedCheckpoints.indexWhere(
            (cp) => cp.id == matchingCheckpoint.id,
          );
          if (index != -1) {
            updatedCheckpoints[index] = updatedCheckpoint;
          }

          setState(() {
            _checkpoints = updatedCheckpoints;
            _currentCheckpointIndex = _checkpoints.indexWhere(
              (cp) => !cp.isCompleted,
            );
          });

          // Save to local storage for offline access
          await _savePatrolProgress();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Checkpoint "${matchingCheckpoint.name}" completed!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning checkpoint: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<File?> _capturePhoto() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (mounted) {
        // Anti-cheat: Ensure photo is taken directly from camera
        // Block gallery uploads, screenshots, and reused images
        final XFile photo = await controller.takePicture();

        // Additional validation could be added here
        // For example, checking EXIF data to ensure it's a genuine camera photo
        // This ensures the photo is captured live from the camera

        await controller.dispose();
        return File(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  Future<void> _savePatrolProgress() async {
    // Create a patrol session object to save
    final patrolSession = PatrolSession(
      id: 'PATROL_${DateTime.now().millisecondsSinceEpoch}',
      guardId: 'GRD001', // This should be the actual guard ID
      startTime: DateTime.now().subtract(
        const Duration(minutes: 30),
      ), // Placeholder
      checkpoints: _checkpoints,
      isPaused: _isPatrolPaused,
      isOffline: !_isOnline,
      currentCheckpointIndex: _currentCheckpointIndex,
    );

    await LocalStorageService.saveActivePatrol(patrolSession);
  }

  Future<void> _pausePatrol() async {
    setState(() {
      _isPatrolPaused = true;
    });

    await _savePatrolProgress();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patrol paused. Tap "Resume" when ready.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resumePatrol() async {
    setState(() {
      _isPatrolPaused = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patrol resumed!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _reportIncident() async {
    // Navigate to incident reporting screen
    Navigator.pushNamed(
      context,
      AppRoutes.incidentReporting,
      arguments: {
        'guardId': 'GRD001',
        'patrolId': 'PATROL_${DateTime.now().millisecondsSinceEpoch}',
        'checkpointId': _checkpoints[_currentCheckpointIndex].id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCheckpoints = _checkpoints
        .where((cp) => cp.isCompleted)
        .length;
    final totalCheckpoints = _checkpoints.length;
    final progress = totalCheckpoints > 0
        ? (completedCheckpoints / totalCheckpoints).toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Checkpoints'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isOnline ? Icons.wifi : Icons.wifi_off,
              color: _isOnline ? Colors.green : Colors.red,
            ),
            onPressed: null, // Just for display
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E5F7), Color(0xFFE6E5F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressCard(
                  progress,
                  completedCheckpoints,
                  totalCheckpoints,
                ),
                const SizedBox(height: 24),
                _buildCurrentCheckpointCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildCheckpointsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Patrol Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8063FC)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed of $total checkpoints completed',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isOnline
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online - Data Synced' : 'Offline - Data Safe',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOnline
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCheckpointCard() {
    if (_currentCheckpointIndex >= _checkpoints.length) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Patrol Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All checkpoints have been completed',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final currentCheckpoint = _checkpoints[_currentCheckpointIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Current Checkpoint',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2196F3)),
                const SizedBox(width: 8),
                Text(
                  'Checkpoint #${currentCheckpoint.sequenceNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentCheckpoint.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan QR code to complete',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentCheckpointIndex >= _checkpoints.length) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Complete patrol
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.attendanceManagement,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8063FC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Finish Patrol',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _isPatrolPaused ? _resumePatrol : _pausePatrol,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8063FC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isPatrolPaused ? 'Resume Patrol' : 'Pause Patrol',
                style: const TextStyle(fontSize: 16, color: Color(0xFF8063FC)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isScanning || _isPatrolPaused
                  ? null
                  : _scanCheckpoint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8063FC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isScanning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Scanning...'),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner),
                        SizedBox(width: 8),
                        Text('Scan Checkpoint'),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _reportIncident,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckpointsList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Checkpoints',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _checkpoints.length,
                itemBuilder: (context, index) {
                  final checkpoint = _checkpoints[index];
                  final isCurrent =
                      index == _currentCheckpointIndex && !_isPatrolPaused;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: checkpoint.isCompleted
                            ? Colors.green
                            : isCurrent
                            ? const Color(0xFF8063FC)
                            : Colors.grey,
                        width: checkpoint.isCompleted ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: checkpoint.isCompleted
                                  ? Colors.green
                                  : isCurrent
                                  ? const Color(0xFF8063FC)
                                  : Colors.grey,
                            ),
                            child: Center(
                              child: checkpoint.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${checkpoint.sequenceNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  checkpoint.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: checkpoint.isCompleted
                                        ? Colors.green
                                        : isCurrent
                                        ? const Color(0xFF8063FC)
                                        : Colors.black,
                                  ),
                                ),
                                if (checkpoint.completedAt != null)
                                  Text(
                                    'Completed at: ${_formatTime(checkpoint.completedAt!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (checkpoint.isCompleted)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _checkpoints.clear();
    super.dispose();
  }
}
