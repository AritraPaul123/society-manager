import 'package:flutter/material.dart';
import 'package:society_man/core/services/face_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/api_service.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class MarkAttendanceOutScreen extends StatefulWidget {
  final String staffId;
  final String guardId;

  const MarkAttendanceOutScreen({
    super.key,
    required this.staffId,
    required this.guardId,
  });

  @override
  State<MarkAttendanceOutScreen> createState() =>
      _MarkAttendanceOutScreenState();
}

class _MarkAttendanceOutScreenState extends State<MarkAttendanceOutScreen> {
  File? _capturedFace;
  bool _isScanning = false;
  bool _isCheckingOut = false;
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
      // Open location settings to allow user to enable location
      await Geolocator.openLocationSettings();
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

    // Set initial location state to loading
    setState(() {
      _location = 'Getting location...';
      _isLocationEnabled = false;
    });

    // Get current location with timeout
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
        _isLocationEnabled = true;
      });
    } catch (e) {
      setState(() {
        _location = 'Unable to get location: ${e.toString()}';
        _isLocationEnabled = false;
      });
    }
  }

  Future<void> _refreshLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
        _isLocationEnabled = false;
      });
      // Open location settings to allow user to enable location
      await Geolocator.openLocationSettings();
      return;
    }

    // Always try to get a fresh location
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
        _isLocationEnabled = true;
      });
    } catch (e) {
      setState(() {
        _location = 'Unable to get location: ${e.toString()}';
        _isLocationEnabled = false;
      });
    }
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

  Future<void> _markAttendanceOut() async {
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

    setState(() {
      _isCheckingOut = true;
    });

    try {
      // Get current location with timeout, regardless of initial status
      String location;
      bool locationEnabled = false;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        location = '${position.latitude}, ${position.longitude}';
        locationEnabled = true;
      } catch (e) {
        location = 'Unable to get location: ${e.toString()}';
        locationEnabled = false;
      }

      if (!locationEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location is required for attendance'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isCheckingOut = false;
        });
        return;
      }

      print('DEBUG: Checking out guard: ${widget.guardId}');

      // Save to backend
      final success = await ApiService().checkOut(widget.guardId);

      print('DEBUG: Check-out API call result: $success');

      if (!success) {
        throw Exception('Failed to check out on server - API returned false');
      }

      // Also save locally
      await LocalStorageService.markAttendanceCheckOut(
        guardId: widget.guardId,
        location: location,
        faceImage: _capturedFace,
      );

      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out recorded successfully! Status: Off Duty'),
            backgroundColor: Colors.green,
          ),
        );

        // Return true to indicate successful check-out
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      print('ERROR: Exception during check-out: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking check-out: ${e.toString()}'),
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
                  _buildCheckoutCard(),
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
      child: const Icon(Icons.logout, size: 48, color: Color(0xFF8063FC)),
    );
  }

  Widget _buildCheckoutCard() {
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
                'Mark Check-Out',
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _refreshLocation,
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: _isLocationEnabled
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Face Scan Section
          _buildFaceScanSection(),

          const SizedBox(height: 24),

          // Mark Attendance Button
          _buildMarkCheckoutButton(),

          const SizedBox(height: 16),

          const Text(
            'Your check-out will be recorded with location and face verification',
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

  Widget _buildMarkCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCheckingOut ? null : _markAttendanceOut,
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
        child: _isCheckingOut
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
                  Text('Marking Check-Out...'),
                ],
              )
            : const Text(
                'Mark Check-Out',
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
