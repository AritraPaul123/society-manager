import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:society_admin_dashboard/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:society_admin_dashboard/core/services/api_service.dart';
import 'package:society_admin_dashboard/features/auth/presentation/screens/admin_login_screen.dart';

void main() {
  runApp(const SocietyAdminApp());
}

class SocietyAdminApp extends StatelessWidget {
  const SocietyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Society Management Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8063FC),
          primary: const Color(0xFF8063FC),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}
