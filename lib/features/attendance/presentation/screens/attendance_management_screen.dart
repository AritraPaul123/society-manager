import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'package:society_man/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  String _dutyStatus = 'Off Duty';
  Color _dutyStatusColor = Colors.red; // Red color for off duty
  bool _isOnDuty = false;
  AttendanceRecord? _currentAttendanceRecord;
  String? _currentStaffId;
  String? _currentGuardId;

  @override
  void initState() {
    super.initState();
    _loadCurrentDutyStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload status when screen becomes active again
    _loadCurrentDutyStatus();
  }

  Future<void> _loadCurrentDutyStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStaffId = prefs.getString('current_staff_id') ?? 'STAFF001';
      _currentGuardId = prefs.getString('current_guard_id') ?? 'GRD001';

      // --- NEW: Try fetching from Backend first ---
      final backendRecord = await ApiService().getAttendanceStatus(
        _currentGuardId!,
      );

      if (backendRecord != null) {
        print('DEBUG: Found attendance record from backend');
        final now = DateTime.now();
        final isToday =
            backendRecord.checkInTime?.year == now.year &&
            backendRecord.checkInTime?.month == now.month &&
            backendRecord.checkInTime?.day == now.day;

        if (backendRecord.checkInTime != null &&
            backendRecord.checkOutTime == null &&
            isToday) {
          setState(() {
            _dutyStatus = 'On Duty';
            _dutyStatusColor = Colors.green;
            _isOnDuty = true;
            _currentAttendanceRecord = backendRecord;
          });
          return; // Skip local check if backend gives us "On Duty"
        }
      }
      // ---------------------------------------------

      // Get all attendance records from Local Storage (Fallback/Offline)
      final List<AttendanceRecord> records =
          await LocalStorageService.getAttendanceRecords();

      // Filter records for the current guard
      final guardRecords = records
          .where((r) => r.guardId == _currentGuardId)
          .toList();

      print(
        'DEBUG: Found ${guardRecords.length} attendance records for guard $_currentGuardId',
      );

      // If no records exist for this guard, default to Off Duty
      if (guardRecords.isEmpty) {
        print('DEBUG: No records found for this guard, setting to Off Duty');
        setState(() {
          _dutyStatus = 'Off Duty';
          _dutyStatusColor = Colors.red;
          _isOnDuty = false;
          _currentAttendanceRecord = null;
        });
        return;
      }

      // Get the most recent record for THIS guard
      final mostRecentRecord = guardRecords.last;
      print(
        'DEBUG: Most recent record - CheckIn: ${mostRecentRecord.checkInTime}, CheckOut: ${mostRecentRecord.checkOutTime}',
      );

      // Check if guard is currently on duty
      // Guard is on duty if they have checked in but not checked out TODAY
      final now = DateTime.now();
      final isToday =
          mostRecentRecord.checkInTime?.year == now.year &&
          mostRecentRecord.checkInTime?.month == now.month &&
          mostRecentRecord.checkInTime?.day == now.day;

      if (mostRecentRecord.checkInTime != null &&
          mostRecentRecord.checkOutTime == null &&
          isToday) {
        // Guard is currently on duty
        print('DEBUG: Guard is ON DUTY - Checked in today and not checked out');
        setState(() {
          _dutyStatus = 'On Duty';
          _dutyStatusColor = Colors.green;
          _isOnDuty = true;
          _currentAttendanceRecord = mostRecentRecord;
        });
      } else {
        // Guard is off duty
        print(
          'DEBUG: Guard is OFF DUTY - Either not checked in today or already checked out',
        );
        setState(() {
          _dutyStatus = 'Off Duty';
          _dutyStatusColor = Colors.red;
          _isOnDuty = false;
          _currentAttendanceRecord = null;
        });
      }
    } catch (e) {
      print('Error loading duty status: $e');
      // Default to off duty on error
      setState(() {
        _dutyStatus = 'Off Duty';
        _dutyStatusColor = Colors.red;
        _isOnDuty = false;
        _currentAttendanceRecord = null;
      });
    }
  }

  // Add this method to force update attendance status
  Future<void> _updateAttendanceStatus(bool isOnDuty) async {
    setState(() {
      _isOnDuty = isOnDuty;
      if (isOnDuty) {
        _dutyStatus = 'On Duty';
        _dutyStatusColor = Colors.green;
      } else {
        _dutyStatus = 'Off Duty';
        _dutyStatusColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAttendanceSection(),
                    const SizedBox(height: 32),
                    _buildDailyOperationsSection(),
                    const SizedBox(height: 32),
                    _buildGuardPatrollingSection(),
                    const SizedBox(height: 32),
                    _buildMarkOutSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo section
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9F7AEA), Color(0xFF805AD5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.layers, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Security Portal',
                style: TextStyle(fontSize: 12, color: Color(0xFF7B7A80)),
              ),
            ],
          ),
          const Spacer(),
          // Profile section
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.guardProfile,
                arguments: _currentGuardId,
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5FA),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF8063FC),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentAttendanceRecord?.guardName ?? 'Rajesh Kumar',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      _dutyStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: _dutyStatusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_currentAttendanceRecord != null &&
                        _currentAttendanceRecord!.checkInTime != null)
                      Text(
                        'Check-in: ${_formatTime(_currentAttendanceRecord!.checkInTime!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF8063FC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF8063FC)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade300.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Attendance Management', Icons.access_time),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8063FC), Color(0xFF6B4FD9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8063FC).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark Attendance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Start your duty shift',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isOnDuty
                              ? null // Disable if already on duty
                              : () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.markAttendance,
                                    arguments: {
                                      'staffId': _currentStaffId ?? 'STAFF001',
                                      'guardId': _currentGuardId ?? 'GRD001',
                                    },
                                  );

                                  // Check if check-in was successful
                                  if (result == true) {
                                    // Immediately update status to On Duty
                                    await _updateAttendanceStatus(true);
                                    // Also reload from storage to get check-in time
                                    await _loadCurrentDutyStatus();
                                  } else {
                                    // If check-in failed or was cancelled, reload status
                                    await _loadCurrentDutyStatus();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: _isOnDuty
                                ? Colors.grey
                                : Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isOnDuty
                              ? const Text(
                                  'Already On Duty',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                )
                              : Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8063FC),
                                        Color(0xFF6B4FD9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8063FC,
                                        ).withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: const Text(
                                      'Mark In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyOperationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daily Operations', Icons.show_chart),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8063FC), Color(0xFF6B4FD9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8063FC).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visitor Log',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage society entries',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8063FC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_outline,
                            color: Color(0xFF8063FC),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  label: 'Scan Emirates ID',
                                  icon: Icons.qr_code_scanner,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.visitorScan,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  label: 'Manual Entry',
                                  icon: Icons.edit_note,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.visitorManual,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  label: 'Active Visitors',
                                  icon: Icons.people_outline,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.activeVisitors,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  label: 'Visitor History',
                                  icon: Icons.history,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.visitorHistory,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isFullWidth = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8063FC), Color(0xFF6B4FD9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8063FC).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            vertical: isFullWidth ? 16 : 12,
            horizontal: 8,
          ),
          child: isFullWidth
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGuardPatrollingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Guard Patrolling', Icons.security),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8063FC), Color(0xFF6B4FD9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8063FC).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patrol Routes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'View and track patrol checkpoints',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isOnDuty
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.guardPatrolStart,
                                  );
                                }
                              : null, // Disable if not on duty
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: _isOnDuty
                                ? Colors.transparent
                                : Colors.grey,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isOnDuty
                              ? Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8063FC),
                                        Color(0xFF6B4FD9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8063FC,
                                        ).withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: const Text(
                                      'Start Patrol',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Start Patrol (Mark In First)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkOutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('End Shift', Icons.logout),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8063FC), Color(0xFF6B4FD9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8063FC).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'End your duty shift',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isOnDuty
                              ? () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.markAttendanceOut,
                                    arguments: {
                                      'staffId': _currentStaffId ?? 'STAFF001',
                                      'guardId': _currentGuardId ?? 'GRD001',
                                    },
                                  );

                                  // Check if check-out was successful
                                  if (result == true) {
                                    // Immediately update status to Off Duty
                                    await _updateAttendanceStatus(false);
                                    // Also reload from storage
                                    await _loadCurrentDutyStatus();
                                  } else {
                                    // If check-out failed or was cancelled, reload status
                                    await _loadCurrentDutyStatus();
                                  }
                                }
                              : null, // Disable if not on duty
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: _isOnDuty
                                ? Colors.transparent
                                : Colors.grey,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isOnDuty
                              ? Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8063FC),
                                        Color(0xFF6B4FD9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8063FC,
                                        ).withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: const Text(
                                      'Mark Out',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Not On Duty',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
