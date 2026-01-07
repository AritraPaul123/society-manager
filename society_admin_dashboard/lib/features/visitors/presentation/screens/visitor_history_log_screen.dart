import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitorHistoryLogScreen extends StatelessWidget {
  const VisitorHistoryLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Visitor History Log',
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
      body: Column(
        children: [
          _buildFiltersSection(context),
          Expanded(child: _buildHistoryTable()),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for "$value"...')),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, unit, or visitor...',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Date Range Picker...')),
              );
            },
            child: Container(
              width: 120,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Dates',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting records to Excel/PDF...'),
                ),
              );
            },
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8063FC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  Widget _buildHistoryTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView(
              children: [
                _buildTableRow(
                  date: '28 Dec 2025',
                  visitorName: 'John Smith',
                  visitorThumb: 'JS',
                  unit: 'A-301',
                  entryTime: '09:45 AM',
                  exitTime: '10:15 AM',
                  guardName: 'Guard Alex',
                  status: 'Approved',
                ),
                _buildTableRow(
                  date: '28 Dec 2025',
                  visitorName: 'Sarah Johnson',
                  visitorThumb: 'SJ',
                  unit: 'B-205',
                  entryTime: '10:30 AM',
                  exitTime: '11:45 AM',
                  guardName: 'Guard Alex',
                  status: 'Approved',
                ),
                _buildTableRow(
                  date: '28 Dec 2025',
                  visitorName: 'Mike Wilson',
                  visitorThumb: 'MW',
                  unit: 'C-102',
                  entryTime: '11:15 AM',
                  exitTime: '---',
                  guardName: 'Guard Sarah',
                  status: 'In Premise',
                ),
                _buildTableRow(
                  date: '27 Dec 2025',
                  visitorName: 'Emily Davis',
                  visitorThumb: 'ED',
                  unit: 'A-405',
                  entryTime: '02:30 PM',
                  exitTime: '04:00 PM',
                  guardName: 'Guard Mike',
                  status: 'Approved',
                ),
                _buildTableRow(
                  date: '27 Dec 2025',
                  visitorName: 'Robert Brown',
                  visitorThumb: 'RB',
                  unit: 'D-301',
                  entryTime: '03:15 PM',
                  exitTime: '03:45 PM',
                  guardName: 'Guard Mike',
                  status: 'Approved',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: const Color(0xFFF9FAFB),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerText('Date')),
          Expanded(flex: 3, child: _headerText('Visitor')),
          Expanded(flex: 2, child: _headerText('Unit Visited')),
          Expanded(flex: 3, child: _headerText('Entry / Exit')),
          Expanded(flex: 2, child: _headerText('Guard')),
          Expanded(flex: 2, child: _headerText('Status')),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _buildTableRow({
    required String date,
    required String visitorName,
    required String visitorThumb,
    required String unit,
    required String entryTime,
    required String exitTime,
    required String guardName,
    required String status,
  }) {
    bool isApproved = status == 'Approved' || status == 'In Premise';
    bool isInPremise = status == 'In Premise';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF8063FC).withOpacity(0.1),
                  child: Text(
                    visitorThumb,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8063FC),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  visitorName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              unit,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, size: 12, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      entryTime,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      size: 12,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exitTime,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              guardName,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isInPremise
                    ? const Color(0xFF8063FC).withOpacity(0.1)
                    : (isApproved
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFEF4444).withOpacity(0.1)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isInPremise
                      ? const Color(0xFF8063FC)
                      : (isApproved
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
