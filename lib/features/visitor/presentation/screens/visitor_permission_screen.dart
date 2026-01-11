import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';

class VisitorPermissionScreen extends StatelessWidget {
  final String visitorName;
  final String visitorPhone;
  final String visitorPurpose;
  final String? visitorCompany;
  final String? eidNumber;

  const VisitorPermissionScreen({
    super.key,
    required this.visitorName,
    required this.visitorPhone,
    required this.visitorPurpose,
    this.visitorCompany,
    this.eidNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEEDF8), Color(0xFFEEEDF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildVisitorDetailsCard(),
                      const SizedBox(height: 24),
                      _buildTakeActionCard(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          child: Center(
            child: Icon(Icons.shield, size: 40, color: const Color(0xFF6366F1)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Visitor Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Security Guard Portal',
          style: TextStyle(fontSize: 16, color: Color(0xFF7D7D7D)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVisitorDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4FC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visitor Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: visitorName,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: visitorPhone,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.work_outline,
            label: 'Purpose',
            value: _capitalizePurpose(visitorPurpose),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8063FC)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7D7D7D)),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTakeActionCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4FC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Take Action',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context: context,
            label: 'Allow Entry',
            icon: Icons.check_circle_outline,
            backgroundColor: const Color(0xFF10B981),
            hoverColor: const Color(0xFF0ea472),
            action: 'allow',
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            label: 'Inform Resident',
            icon: Icons.notifications_outlined,
            backgroundColor: const Color(0xFFF59E0B),
            hoverColor: const Color(0xFFdc8b09),
            action: 'inform',
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            label: 'Deny Entry',
            icon: Icons.cancel_outlined,
            backgroundColor: const Color(0xFFEF4444),
            hoverColor: const Color(0xFFdc2626),
            action: 'deny',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color hoverColor,
    required String action,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleAction(context, action),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    // Log the action
    print('Action taken: $action');
    print(
      'Visitor: $visitorName, Phone: $visitorPhone, Purpose: $visitorPurpose',
    );

    String status = 'pending_resident';
    if (action == 'allow') status = 'allowed';
    if (action == 'deny') status = 'denied';

    // Save visitor entry
    final entry = VisitorEntry(
      id: 'VIS_${DateTime.now().millisecondsSinceEpoch}',
      eidNumber: eidNumber ?? 'N/A',
      visitorName: visitorName,
      phoneNumber: visitorPhone,
      purpose: visitorPurpose,
      companyName: visitorCompany,
      entryTime: DateTime.now(),
      guardId: 1, // Guard user ID from database
      status: status,
    );

    await LocalStorageService.saveVisitorEntry(entry);

    // Show a confirmation message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'allow'
                ? 'Entry allowed for $visitorName'
                : action == 'inform'
                ? 'Resident has been informed about $visitorName'
                : 'Entry denied for $visitorName',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to attendance management
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.attendanceManagement,
            (route) => false,
          );
        }
      });
    }
  }

  String _capitalizePurpose(String purpose) {
    if (purpose.isEmpty) return purpose;
    return purpose[0].toUpperCase() + purpose.substring(1);
  }
}
