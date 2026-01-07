import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuardReportsScreen extends StatelessWidget {
  const GuardReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Guard Performance Reports',
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
                const SnackBar(
                  content: Text('Generating comprehensive PDF report...'),
                ),
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
          children: [
            _buildSummaryRow(),
            const SizedBox(height: 32),
            _buildGuardList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('94%', 'Avg Attendance')),
        const SizedBox(width: 24),
        Expanded(child: _buildSummaryCard('88%', 'Avg Completion')),
        const SizedBox(width: 24),
        Expanded(child: _buildSummaryCard('35', 'Total Incidents')),
        const SizedBox(width: 24),
        Expanded(child: _buildSummaryCard('4.6', 'Avg Rating')),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF8063FC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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

  Widget _buildGuardList(BuildContext context) {
    return Column(
      children: [
        _buildGuardPerformanceCard(
          context: context,
          name: 'John Doe',
          initials: 'JD',
          shift: 'Morning (6 AM - 2 PM)',
          attendance: 0.98,
          completion: 0.95,
          incidents: 8,
          rating: 4.8,
          status: 'Performance: Good',
          missedPatrols: 2,
        ),
        const SizedBox(height: 24),
        _buildGuardPerformanceCard(
          context: context,
          name: 'Jane Smith',
          initials: 'JS',
          shift: 'Afternoon (2 PM - 10 PM)',
          attendance: 1.0,
          completion: 0.92,
          incidents: 12,
          rating: 4.9,
          status: 'Performance: Good',
          missedPatrols: 1,
        ),
        const SizedBox(height: 24),
        _buildGuardPerformanceCard(
          context: context,
          name: 'Mike Johnson',
          initials: 'MJ',
          shift: 'Night (10 PM - 6 AM)',
          attendance: 0.85,
          completion: 0.78,
          incidents: 5,
          rating: 4.2,
          status: 'Performance below threshold',
          isWarning: true,
          missedPatrols: 12,
        ),
        const SizedBox(height: 24),
        _buildGuardPerformanceCard(
          context: context,
          name: 'Sarah Williams',
          initials: 'SW',
          shift: 'Morning (6 AM - 2 PM)',
          attendance: 0.96,
          completion: 0.88,
          incidents: 10,
          rating: 4.6,
          status: 'Performance: Good',
          missedPatrols: 3,
        ),
      ],
    );
  }

  Widget _buildGuardPerformanceCard({
    required BuildContext context,
    required String name,
    required String initials,
    required String shift,
    required double attendance,
    required double completion,
    required int incidents,
    required double rating,
    required String status,
    bool isWarning = false,
    int missedPatrols = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFFBEB) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning ? const Color(0xFFFEF3C7) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF8063FC),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      shift,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFF8063FC),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$rating / 5.0',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildMetricBar(
                  'Attendance',
                  attendance,
                  '${(attendance * 100).toInt()}%',
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildMetricBar(
                  'Patrol Completion',
                  completion,
                  '${(completion * 100).toInt()}%',
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missed Patrols',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      missedPatrols.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: missedPatrols > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incidents Filed',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incidents.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isWarning)
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isWarning
                          ? const Color(0xFFD97706)
                          : const Color(0xFF6B7280),
                      fontWeight: isWarning
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Viewing detailed performance history for $name',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8063FC),
                  side: const BorderSide(color: Color(0xFF8063FC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            Text(
              percentage,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8063FC)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
