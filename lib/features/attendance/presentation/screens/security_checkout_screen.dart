import 'package:flutter/material.dart';
import 'package:society_man/core/services/face_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'dart:io';

class SecurityCheckoutScreen extends StatefulWidget {
  const SecurityCheckoutScreen({super.key});

  @override
  State<SecurityCheckoutScreen> createState() => _SecurityCheckoutScreenState();
}

class _SecurityCheckoutScreenState extends State<SecurityCheckoutScreen> {
  File? _capturedFace;
  bool isScanning = false;

  Future<void> _handleCheckout() async {
    setState(() {
      isScanning = true;
    });

    try {
      final File? faceImage = await FaceScannerService.scanFace(context);
      if (faceImage != null && mounted) {
        setState(() {
          _capturedFace = faceImage;
          isScanning = false;
        });

        // Simulate checkout processing
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checkout successful! Have a great day!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to welcome screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.welcome,
            (route) => false,
          );
        }
      } else {
        setState(() {
          isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isScanning = false;
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
      backgroundColor: const Color(0xFFEEEDF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 24),
                _buildMainCard(),
              ],
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/icons/app_logo.jpg',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildScanCircle(),
          const SizedBox(height: 32),
          _buildCheckoutButton(),
          const SizedBox(height: 24),
          _buildFooterText(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Security Check-Out',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: -0.5,
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
    );
  }

  Widget _buildScanCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8063FC).withOpacity(0.55),
              width: 2,
            ),
          ),
        ),
        // Main circle
        Container(
          width: 192,
          height: 192,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEEEDF8),
          ),
          child: Center(
            child: AnimatedOpacity(
              opacity: isScanning ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: const Color(0xFF8063FC),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isScanning ? null : _handleCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8063FC),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF8063FC).withOpacity(0.7),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          isScanning ? 'Processing...' : 'End of Shift Confirmation',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return const Text(
      'Your attendance will be recorded instantly',
      style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
      textAlign: TextAlign.center,
    );
  }
}
