import 'package:flutter/material.dart';
import 'package:society_man/core/services/qr_scanner_service.dart';
import 'package:society_man/core/routes/app_routes.dart';

class VisitorManagementScanScreen extends StatelessWidget {
  const VisitorManagementScanScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildScanCard(),
                        const SizedBox(height: 32),
                        _buildBackButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
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
          child: const Icon(Icons.layers, size: 40, color: Color(0xFF8063FC)),
        ),
        const SizedBox(height: 24),
        const Column(
          children: [
            Text(
              'Visitor Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Security Guard Portal',
              style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScanArea(),
          const SizedBox(height: 24),
          const Text(
            'Scan Visitor EID',
            style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildScanButton(),
        ],
      ),
    );
  }

  Widget _buildScanArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 250),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8063FC), width: 1.4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 64,
              color: const Color(0xFF8063FC),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to scan',
              style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Builder(
      builder: (context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final emiratesIdData = await QRScannerService.scanEmiratesId(
              context,
            );
            if (emiratesIdData != null && context.mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.visitorEntryScan,
                arguments: {
                  'eidNumber': emiratesIdData.idNumber,
                  'visitorName': emiratesIdData.fullName,
                  'nationality': emiratesIdData.nationality,
                  'isDraft': false,
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8063FC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF8063FC).withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Scan EID',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, size: 16, color: Color(0xFF7B7A80)),
          SizedBox(width: 4),
          Text(
            'Back to Dashboard',
            style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
          ),
        ],
      ),
    );
  }
}
