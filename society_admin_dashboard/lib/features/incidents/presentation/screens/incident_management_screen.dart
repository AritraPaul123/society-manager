import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncidentManagementScreen extends StatelessWidget {
  const IncidentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Incident Management',
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
            _buildIncidentItem(
              context: context,
              title: 'Suspicious Activity - Parking Lot',
              description: 'Unknown individual loitering around vehicles',
              time: '2 hours ago',
              location: 'North Parking - Level 3',
              reporter: 'Guard John Doe',
              priority: 'HIGH',
              status: 'OPEN',
              statusColor: const Color(0xFF8063FC),
              priorityColor: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            _buildIncidentItem(
              context: context,
              title: 'Gate Malfunction',
              description: 'Main gate not closing properly',
              time: '4 hours ago',
              location: 'Main Gate A',
              reporter: 'Guard Jane Smith',
              priority: 'MEDIUM',
              status: 'IN REVIEW',
              statusColor: const Color(0xFFF59E0B),
              priorityColor: const Color(0xFFF59E0B),
              assignedTeam: 'Maintenance Team',
            ),
            const SizedBox(height: 16),
            _buildIncidentItem(
              context: context,
              title: 'Noise Complaint',
              description: 'Loud music after 10 PM',
              time: '6 hours ago',
              location: 'Building C - Unit 302',
              reporter: 'Resident - Unit 301',
              priority: 'LOW',
              status: 'OPEN',
              statusColor: const Color(0xFF8063FC),
              priorityColor: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 16),
            _buildIncidentItem(
              context: context,
              title: 'Unauthorized Entry Attempt',
              description: 'Individual tried to enter without credentials',
              time: '1 hour ago',
              location: 'Service Entrance',
              reporter: 'Guard Mike Johnson',
              priority: 'HIGH',
              status: 'OPEN',
              statusColor: const Color(0xFF8063FC),
              priorityColor: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            _buildIncidentItem(
              context: context,
              title: 'Security Camera Offline',
              description: 'Camera lost connection',
              time: '8 hours ago',
              location: 'East Wing - Camera 12',
              reporter: 'System Alert',
              priority: 'MEDIUM',
              status: 'IN REVIEW',
              statusColor: const Color(0xFFF59E0B),
              priorityColor: const Color(0xFFF59E0B),
              assignedTeam: 'IT Team',
            ),
            const SizedBox(height: 16),
            _buildIncidentItem(
              context: context,
              title: 'Water Leakage - Building B',
              description: 'Plumbing issue in the main pipe',
              time: '1 day ago',
              location: 'Building B - Basement',
              reporter: 'Guard Sarah Williams',
              priority: 'HIGH',
              status: 'RESOLVED',
              statusColor: const Color(0xFF10B981),
              priorityColor: const Color(0xFFEF4444),
              assignedTeam: 'Maintenance Team',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentItem({
    required BuildContext context,
    required String title,
    required String description,
    required String time,
    required String location,
    required String reporter,
    required String priority,
    required String status,
    required Color statusColor,
    required Color priorityColor,
    String? assignedTeam,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Color(0xFF8063FC),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: priorityColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      priority,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reporter,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
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
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (assignedTeam != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 32),
                const Icon(
                  Icons.near_me_outlined,
                  size: 14,
                  color: Color(0xFF111827),
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned: $assignedTeam',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                if (status == 'RESOLVED')
                  Text(
                    'Time taken: 45m',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 32),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note editor opened...')),
                  );
                },
                icon: const Icon(Icons.add_comment_outlined, size: 18),
                label: const Text('Add Note'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4B5563),
                ),
              ),
              const Spacer(),
              if (status != 'RESOLVED') ...[
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reassigning incident: $title')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8063FC),
                    side: const BorderSide(color: Color(0xFF8063FC)),
                    elevation: 0,
                  ),
                  child: const Text('Assign Owner'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Incident $title marked as RESOLVED'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8063FC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Close Ticket'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
