import 'package:flutter/material.dart';
import 'package:society_man/core/services/qr_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';

class GuardSimulateScanScreen extends StatelessWidget {
  const GuardSimulateScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(child: _buildQRScannerCard()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/icons/app_logo.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
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
                height: 1.5,
                letterSpacing: -0.312,
              ),
            ),
            Text(
              'Field Operations Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF7B7A80),
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQRScannerCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
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
          _buildCardHeader(),
          const SizedBox(height: 24),
          _buildQRCodeDisplay(),
          const SizedBox(height: 24),
          _buildSimulateButton(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return const Column(
      children: [
        Text(
          'Scan QR Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.5,
            letterSpacing: -0.439,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Main Entrance Gate',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            height: 1.5,
            letterSpacing: -0.312,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(32),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8063FC), width: 3.39),
          ),
          child: Stack(
            children: [
              // QR Code Icon
              Center(
                child: Opacity(
                  opacity: 0.4,
                  child: Icon(
                    Icons.qr_code_2,
                    size: 96,
                    color: const Color(0xFF8063FC),
                  ),
                ),
              ),
              // Scan line animation
              Center(
                child: Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8063FC).withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulateButton() {
    return Builder(
      builder: (context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            final String? qrData = await QRScannerService.scanQRCode(context);
            if (qrData != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('QR Scanned: $qrData'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate to active patrol screen
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.guardActivePatrol,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8063FC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Simulate QR Scan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                  letterSpacing: -0.312,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
