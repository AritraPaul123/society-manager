import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatrolEvidenceScreen extends StatelessWidget {
  const PatrolEvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Patrol Evidence \u0026 Checkpoints',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting patrol summary...')),
              );
            },
            icon: const Icon(
              Icons.file_download_outlined,
              color: Color(0xFF6B7280),
            ),
          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDatePicker(context),
            const SizedBox(height: 32),
            _buildSummaryRow(),
            const SizedBox(height: 32),
            _buildPatrolList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        Text(
          'Date:',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Calendar...')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'Dec 28, 2025',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            '6',
            'Completed Patrols',
            const Color(0xFF8063FC).withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            '2',
            'Missed Checkpoints',
            const Color(0xFF8063FC).withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            '22',
            'Photo Evidence',
            const Color(0xFF8063FC).withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatrolList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRouteHeader('Route A - Morning Perimeter'),
        _buildPatrolItem(
          context: context,
          location: 'Checkpoint 1: Main Gate A',
          time: '08:00 AM',
          guard: 'John Doe',
          photoCount: 1,
          isCompleted: true,
          evidenceCaptured: 'QR + Photo',
        ),
        _buildPatrolItem(
          context: context,
          location: 'Checkpoint 2: North Boundary',
          time: '08:15 AM',
          guard: 'John Doe',
          photoCount: 1,
          isCompleted: true,
          evidenceCaptured: 'QR + Photo',
        ),
        _buildPatrolItem(
          context: context,
          location: 'Checkpoint 3: Service Entrance',
          time: '08:30 AM',
          guard: 'John Doe',
          photoCount: 1,
          isCompleted: true,
          evidenceCaptured: 'QR + Photo',
        ),
        const SizedBox(height: 32),
        _buildRouteHeader('Route B - Afternoon Utility Check'),
        _buildPatrolItem(
          context: context,
          location: 'Checkpoint 1: Transformer Room',
          time: '02:00 PM',
          guard: 'Jane Smith',
          photoCount: 2,
          isCompleted: true,
          evidenceCaptured: 'QR + Photo',
        ),
        _buildPatrolItem(
          context: context,
          location: 'Checkpoint 2: Water Tank Area',
          time: '02:30 PM',
          guard: 'Jane Smith',
          photoCount: 0,
          isCompleted: false,
          evidenceCaptured: 'MISSING',
        ),
      ],
    );
  }

  Widget _buildRouteHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildPatrolItem({
    required BuildContext context,
    required String location,
    required String time,
    required String guard,
    required int photoCount,
    required bool isCompleted,
    required String evidenceCaptured,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF9FAFB) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFE5E7EB)
              : const Color(0xFFFEE2E2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 20,
              color: isCompleted
                  ? const Color(0xFF8063FC)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
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
                    const SizedBox(width: 16),
                    Text(
                      'Guard: $guard',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$photoCount photos',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          evidenceCaptured,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isCompleted)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening evidence gallery for $location'),
                  ),
                );
              },
              icon: const Icon(Icons.photo_library_outlined, size: 16),
              label: const Text('View Photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8063FC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }
}
