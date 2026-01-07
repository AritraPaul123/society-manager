import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _enableFaceId = true;
  double _threshold = 0.8;
  bool _autoClockOut = true;
  bool _alertMissedPatrol = true;
  bool _nightPatrolRequired = true;

  final TextEditingController _gracePeriodController = TextEditingController(
    text: '15',
  );
  final TextEditingController _patrolFreqController = TextEditingController(
    text: '60',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Security Settings \u0026 Config',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8063FC),
          labelColor: const Color(0xFF8063FC),
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Global Settings'),
            Tab(text: 'Patrol Routes'),
            Tab(text: 'QR Points'),
            Tab(text: 'User Roles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalSettingsTab(),
          _buildPatrolRoutesTab(),
          _buildQRPointsTab(),
          _buildUserRolesTab(),
        ],
      ),
    );
  }

  Widget _buildGlobalSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFaceIdSection(),
          const SizedBox(height: 24),
          _buildAttendanceSection(),
          const SizedBox(height: 24),
          _buildPatrolSection(),
          const SizedBox(height: 48),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFaceIdSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.face_retouching_natural,
                size: 20,
                color: Color(0xFF8063FC),
              ),
              const SizedBox(width: 12),
              Text(
                'Face ID Recognition',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enable Face ID',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Switch(
                value: _enableFaceId,
                onChanged: (v) {
                  setState(() => _enableFaceId = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(v ? 'Face ID enabled' : 'Face ID disabled'),
                    ),
                  );
                },
                activeColor: const Color(0xFF8063FC),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Recognition Threshold: ${(_threshold * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF8063FC).withOpacity(0.3),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: const Color(0xFF8063FC),
              trackHeight: 4,
            ),
            child: Slider(
              value: _threshold,
              onChanged: (v) => setState(() => _threshold = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less Strict',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                'More Strict',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: Color(0xFF8063FC)),
              const SizedBox(width: 12),
              Text(
                'Attendance Rules',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Grace Period (minutes)',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(_gracePeriodController),
          const SizedBox(height: 4),
          Text(
            'Allow late clock-in within this period',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto Clock-Out at Shift End',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Switch(
                value: _autoClockOut,
                onChanged: (v) {
                  setState(() => _autoClockOut = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        v
                            ? 'Auto Clock-Out enabled'
                            : 'Auto Clock-Out disabled',
                      ),
                    ),
                  );
                },
                activeColor: const Color(0xFF8063FC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatrolSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_run,
                size: 20,
                color: Color(0xFF8063FC),
              ),
              const SizedBox(width: 12),
              Text(
                'Patrol Requirements',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Patrol Frequency (minutes)',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(_patrolFreqController),
          const SizedBox(height: 4),
          Text(
            'Time between checkpoint scans',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alert on Missed Checkpoint',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Switch(
                value: _alertMissedPatrol,
                onChanged: (v) {
                  setState(() => _alertMissedPatrol = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        v
                            ? 'Missed patrol alerts enabled'
                            : 'Missed patrol alerts disabled',
                      ),
                    ),
                  );
                },
                activeColor: const Color(0xFF8063FC),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Night Patrol Required',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Switch(
                value: _nightPatrolRequired,
                onChanged: (v) {
                  setState(() => _nightPatrolRequired = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        v
                            ? 'Night patrol requirement enabled'
                            : 'Night patrol requirement disabled',
                      ),
                    ),
                  );
                },
                activeColor: const Color(0xFF8063FC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatrolRoutesTab() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Defined Patrol Routes',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Route Builder...')),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Route'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8063FC),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildRouteCard(
                  'Route A - Morning Perimeter',
                  '5 Checkpoints',
                  'Every 60 mins',
                ),
                _buildRouteCard(
                  'Route B - Day Utility Check',
                  '8 Checkpoints',
                  'Every 120 mins',
                ),
                _buildRouteCard(
                  'Night Route - Security Sweep',
                  '12 Checkpoints',
                  'Every 45 mins',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String title, String checkpoints, String freq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.route_outlined, color: Color(0xFF8063FC)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$checkpoints • $freq',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Editing $title...')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQRPointsTab() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active QR Points',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating secure QR point...'),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text('Generate New QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8063FC),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQRItem('Main Gate A', true),
                _buildQRItem('North Boundary - P1', true),
                _buildQRItem('South Entrance', true),
                _buildQRItem('Transformer Room', true),
                _buildQRItem('Building B Roof', false),
                _buildQRItem('Gym Backdoor', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRItem(String name, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code,
            color: isActive ? const Color(0xFF8063FC) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isActive,
              onChanged: (v) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v ? '$name activated' : '$name deactivated'),
                  ),
                );
              },
              activeColor: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRolesTab() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management & Permissions',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildRoleItem(
                  'Security Guard',
                  'Access to patrol, visitor log, and incident reporting.',
                  24,
                  Icons.security,
                ),
                _buildRoleItem(
                  'Supervisor',
                  'Access to reports, staff management, and patrol config.',
                  4,
                  Icons.supervisor_account,
                ),
                _buildRoleItem(
                  'Admin',
                  'Full system access including society configuration.',
                  2,
                  Icons.admin_panel_settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem(
    String role,
    String description,
    int userCount,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF8063FC).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF8063FC)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              '$userCount Users',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Managing permissions for $role...')),
              );
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security configuration saved!')),
              );
              Future.delayed(
                const Duration(seconds: 1),
                () => Navigator.pop(context),
              );
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8063FC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4B5563),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
