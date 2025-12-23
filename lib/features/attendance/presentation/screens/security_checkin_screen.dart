import 'package:flutter/material.dart';
import 'package:society_man/core/services/face_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'dart:io';

class SecurityCheckinScreen extends StatefulWidget {
  const SecurityCheckinScreen({super.key});

  @override
  State<SecurityCheckinScreen> createState() => _SecurityCheckinScreenState();
}

class _SecurityCheckinScreenState extends State<SecurityCheckinScreen> {
  File? _capturedFace;
  bool _isScanning = false;

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

        // Simulate attendance marking
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance marked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to attendance management or dashboard
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.attendanceManagement,
          );
        }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                  _buildCheckinCard(context),
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
      child: const Icon(Icons.layers, size: 48, color: Color(0xFF8063FC)),
    );
  }

  Widget _buildCheckinCard(BuildContext context) {
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
                'Security Check-In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Tap below to mark your attendance',
                style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 48),
          _buildScanButton(),
          const SizedBox(height: 48),
          _buildMarkAttendanceButton(),
          const SizedBox(height: 32),
          const Text(
            'Your attendance will be recorded instantly',
            style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _isScanning ? null : _handleFaceScan,
      child: Container(
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
        child: Center(
          child: Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: const Color(0xFF8063FC),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkAttendanceButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle mark attendance
        },
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
        child: const Text(
          'Mark Attendance',
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
