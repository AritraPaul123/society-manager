import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Staff Management',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Staff registration form opened...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Add New Guard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8063FC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildStaffCard(
              context: context,
              name: 'John Doe',
              shift: 'Morning (6 AM - 2 PM)',
              zone: 'North Zone',
              phone: '+1 (555) 123-4567',
            ),
            const SizedBox(height: 24),
            _buildStaffCard(
              context: context,
              name: 'Jane Smith',
              shift: 'Afternoon (2 PM - 10 PM)',
              zone: 'South Zone',
              phone: '+1 (555) 234-5678',
            ),
            const SizedBox(height: 24),
            _buildStaffCard(
              context: context,
              name: 'Mike Johnson',
              shift: 'Night (10 PM - 6 AM)',
              zone: 'Full Perimeter',
              phone: '+1 (555) 345-6789',
            ),
            const SizedBox(height: 24),
            _buildStaffCard(
              context: context,
              name: 'Sarah Williams',
              shift: 'Morning (6 AM - 2 PM)',
              zone: 'East Zone',
              phone: '+1 (555) 456-7890',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard({
    required BuildContext context,
    required String name,
    required String shift,
    required String zone,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    context,
                    Icons.edit_outlined,
                    const Color(0xFF8063FC),
                    'Editing $name profile...',
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    context,
                    Icons.delete_outline,
                    const Color(0xFFEF4444),
                    'Removing $name from staff roster...',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      shift,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      zone,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Phone: $phone',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    Color color,
    String message,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
