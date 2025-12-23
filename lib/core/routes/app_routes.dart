import 'package:flutter/material.dart';
import 'package:society_man/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:society_man/features/auth/presentation/screens/unified_login_screen.dart';
import 'package:society_man/features/auth/presentation/screens/admin_login_screen.dart';
import 'package:society_man/features/auth/presentation/screens/resident_login_screen.dart';
import 'package:society_man/features/attendance/presentation/screens/attendance_management_screen.dart';
import 'package:society_man/features/attendance/presentation/screens/security_checkin_screen.dart';
import 'package:society_man/features/attendance/presentation/screens/security_checkout_screen.dart';
import 'package:society_man/features/attendance/presentation/screens/mark_attendance_screen.dart';
import 'package:society_man/features/visitor/presentation/screens/visitor_management_scan_screen.dart';
import 'package:society_man/features/visitor/presentation/screens/visitor_management_manual_screen.dart';
import 'package:society_man/features/visitor/presentation/screens/visitor_entry_scan_screen.dart';
import 'package:society_man/features/visitor/presentation/screens/visitor_permission_screen.dart';
import 'package:society_man/features/attendance/presentation/screens/mark_attendance_out_screen.dart';
import 'package:society_man/features/guard/presentation/screens/guard_patrol_dashboard_screen.dart';
import 'package:society_man/features/guard/presentation/screens/guard_patrol_dashboard_start_screen.dart'
    as start;
import 'package:society_man/features/guard/presentation/screens/guard_patrol_scan_screen.dart';
import 'package:society_man/features/guard/presentation/screens/guard_simulate_scan_screen.dart';
import 'package:society_man/features/guard/presentation/screens/guard_active_patrol_screen.dart';
import 'package:society_man/features/guard/presentation/screens/enhanced_patrol_screen.dart';
import 'package:society_man/features/guard/presentation/screens/incident_reporting_screen.dart';
import 'package:society_man/features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String guardLogin = '/guard-login';
  static const String adminLogin = '/admin-login';
  static const String residentLogin = '/resident-login';
  static const String adminDashboard = '/admin-dashboard';
  static const String attendanceManagement = '/attendance-management';
  static const String securityCheckin = '/security-checkin';
  static const String securityCheckout = '/security-checkout';
  static const String markAttendance = '/mark-attendance';
  static const String markAttendanceOut = '/mark-attendance-out';
  static const String visitorScan = '/visitor-scan';
  static const String visitorManual = '/visitor-manual';
  static const String visitorEntryScan = '/visitor-entry-scan';
  static const String visitorPermission = '/visitor-permission';
  static const String guardPatrolDashboard = '/guard-patrol-dashboard';
  static const String guardPatrolStart = '/guard-patrol-start';
  static const String guardPatrolScan = '/guard-patrol-scan';
  static const String guardSimulateScan = '/guard-simulate-scan';
  static const String guardActivePatrol = '/guard-active-patrol';
  static const String enhancedPatrol = '/enhanced-patrol';
  static const String incidentReporting = '/incident-reporting';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      guardLogin: (context) => const UnifiedLoginScreen(),
      adminLogin: (context) => const AdminLoginScreen(),
      residentLogin: (context) => const ResidentLoginScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      attendanceManagement: (context) => const AttendanceManagementScreen(),
      securityCheckin: (context) => const SecurityCheckinScreen(),
      securityCheckout: (context) => const SecurityCheckoutScreen(),
      markAttendance: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final staffId = args?['staffId'] as String? ?? 'STAFF001';
        final guardId = args?['guardId'] as String? ?? 'GRD001';
        return MarkAttendanceScreen(staffId: staffId, guardId: guardId);
      },
      markAttendanceOut: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final staffId = args?['staffId'] as String? ?? 'STAFF001';
        final guardId = args?['guardId'] as String? ?? 'GRD001';
        return MarkAttendanceOutScreen(staffId: staffId, guardId: guardId);
      },
      visitorScan: (context) => const VisitorManagementScanScreen(),
      visitorManual: (context) => const VisitorManagementManualScreen(),
      guardPatrolDashboard: (context) => const GuardPatrolDashboardScreen(),
      guardPatrolStart: (context) => const start.GuardPatrolDashboardScreen(),
      guardPatrolScan: (context) => const GuardPatrolScanScreen(),
      guardSimulateScan: (context) => const GuardSimulateScanScreen(),
      guardActivePatrol: (context) => const GuardActivePatrolScreen(),
      enhancedPatrol: (context) =>
          const EnhancedPatrolScreen(guardId: 'GRD001'),
      incidentReporting: (context) => const IncidentReportingScreen(
        guardId: 'GRD001',
        patrolId: 'PAT001',
        checkpointId: 'CP001',
      ),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case visitorEntryScan:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => VisitorEntryScanScreen(
            eidNumber: args?['eidNumber'] as String?,
            visitorName: args?['visitorName'] as String?,
            nationality: args?['nationality'] as String?,
            isDraft: args?['isDraft'] as bool? ?? false,
          ),
        );
      case visitorPermission:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => VisitorPermissionScreen(
            visitorName: args['visitorName'] as String,
            visitorPhone: args['visitorPhone'] as String,
            visitorPurpose: args['visitorPurpose'] as String,
            visitorCompany: args['visitorCompany'] as String?,
          ),
        );
      case markAttendance:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => MarkAttendanceScreen(
            staffId: args['staffId'] as String,
            guardId: args['guardId'] as String,
          ),
        );
      default:
        return null;
    }
  }
}
