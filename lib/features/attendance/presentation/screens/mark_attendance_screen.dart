import 'package:flutter/material.dart';
import 'package:society_man/core/services/face_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String staffId;
  final String guardId;

  const MarkAttendanceScreen({
    super.key,
    required this.staffId,
    required this.guardId,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  File? _capturedFace;
  bool _isScanning = false;
  bool _isCheckingIn = false;
  String? _location;
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
        _isLocationEnabled = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
          _isLocationEnabled = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied';
        _isLocationEnabled = false;
      });
      return;
    }

    // Get current location
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = '${position.latitude}, ${position.longitude}';
      _isLocationEnabled = true;
    });
  }

  Future<void> _handleFaceScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final File? faceImage = await FaceScannerService.scanFace(context);
      if (faceImage != null && mounted) {
        setState(() {
          _capturedFace = faceImage;
          _isScanning = false;
        });
      } else {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAttendance() async {
    if (_capturedFace == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please scan your face first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!_isLocationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location is required for attendance'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition();
      final location = '${position.latitude}, ${position.longitude}';

      // Create attendance record
      final attendanceRecord = AttendanceRecord(
        guardId: widget.guardId,
        staffId: widget.staffId,
        checkInTime: DateTime.now(),
        location: location,
        status: AttendanceStatus.onDuty,
        checkInFaceImage: _capturedFace,
      );

      await LocalStorageService.saveAttendanceRecord(attendanceRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance marked successfully! Status: On Duty'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to patrol dashboard
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.guardPatrolDashboard,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking attendance: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E5F7), Color(0xFFE6E5F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildCheckinCard(),
                  const SizedBox(height: 24),
                  _buildBackButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.access_time, size: 48, color: Color(0xFF8063FC)),
    );
  }

  Widget _buildCheckinCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Column(
            children: [
              Text(
                'Mark Attendance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Face ID verification required',
                style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Staff ID Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.badge, size: 20, color: Color(0xFF8063FC)),
                const SizedBox(width: 8),
                Text(
                  'Staff ID: ${widget.staffId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8063FC),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Location Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isLocationEnabled
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isLocationEnabled
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isLocationEnabled ? Icons.location_on : Icons.location_off,
                  size: 20,
                  color: _isLocationEnabled
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _location ?? 'Getting location...',
                    style: TextStyle(
                      fontSize: 14,
                      color: _isLocationEnabled
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Face Scan Section
          _buildFaceScanSection(),

          const SizedBox(height: 24),

          // Mark Attendance Button
          _buildMarkAttendanceButton(),

          const SizedBox(height: 16),

          const Text(
            'Your attendance will be recorded with location and face verification',
            style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaceScanSection() {
    return Column(
      children: [
        Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E5F7),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8063FC).withOpacity(0.55),
              width: 2.7,
            ),
          ),
          child: _capturedFace != null
              ? ClipOval(
                  child: Image.file(
                    _capturedFace!,
                    fit: BoxFit.cover,
                    width: 192,
                    height: 192,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.face,
                    size: 64,
                    color: const Color(0xFF8063FC),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isScanning ? null : _handleFaceScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8063FC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isScanning
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Scanning...'),
                  ],
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, size: 16),
                    SizedBox(width: 8),
                    Text('Scan Face'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMarkAttendanceButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCheckingIn ? null : _markAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8063FC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF8063FC).withOpacity(0.3),
        ),
        child: _isCheckingIn
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Marking Attendance...'),
                ],
              )
            : const Text(
                'Mark Check-In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF7B7A80)),
      label: const Text(
        'Back to Dashboard',
        style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
      ),
    );
  }
}
