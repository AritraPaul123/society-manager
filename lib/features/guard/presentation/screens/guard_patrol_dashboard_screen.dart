import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';

class GuardPatrolDashboardScreen extends StatelessWidget {
  const GuardPatrolDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(child: _buildPatrolCard()),
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

  Widget _buildPatrolCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 361),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOnlineStatusBadge(),
          const SizedBox(height: 32),
          _buildBuildingInfo(),
          const SizedBox(height: 28),
          _buildDurationTypeInfo(),
          const SizedBox(height: 40),
          _buildStartPatrolButton(),
        ],
      ),
    );
  }

  Widget _buildOnlineStatusBadge() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C950).withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.wifi, size: 16, color: const Color(0xFF00A63E)),
          const SizedBox(width: 8),
          const Text(
            'Online',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E5F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            size: 24,
            color: Color(0xFF8063FC),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Building A - Night Patrol',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -0.2,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '12 checkpoints',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF7B7A80),
                  letterSpacing: -0.2,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationTypeInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(label: 'Duration', value: '~45 min'),
          _buildInfoItem(label: 'Type', value: 'Night Patrol'),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            letterSpacing: -0.2,
            height: 1.43,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            letterSpacing: -0.2,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStartPatrolButton() {
    return Builder(
      builder: (context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.guardPatrolScan);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8063FC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Start Patrol',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
