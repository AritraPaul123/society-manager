import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';

class ResidentLoginScreen extends StatefulWidget {
  const ResidentLoginScreen({super.key});

  @override
  State<ResidentLoginScreen> createState() => _ResidentLoginScreenState();
}

class _ResidentLoginScreenState extends State<ResidentLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would verify the PIN against stored data
      // For now, we'll simulate a successful login
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navigate to resident dashboard (for now redirecting to attendance management as placeholder)
        Navigator.pushReplacementNamed(context, AppRoutes.attendanceManagement);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B6FD8), Color(0xFF7B68C7), Color(0xFFB666A3)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 67,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://api.builder.io/api/v1/image/assets/TEMP/013e9dea935222b0ca8677c6d0d323864d241d9d?width=134",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 20),
                          blurRadius: 60,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF8B7DD8),
                                    Color(0xFF9F88E8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 10),
                                    blurRadius: 15,
                                    spreadRadius: -3,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 4),
                                    blurRadius: 6,
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.home_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const Text(
                              "Resident Login",
                              style: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF101828),
                                height: 1.5,
                                letterSpacing: -0.258,
                              ),
                            ),
                            const Text(
                              "Enter your secure PIN",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6A7282),
                                height: 1.5,
                                letterSpacing: -0.076,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // PIN Input Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SECURE PIN",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF364153),
                                height: 1.5,
                                letterSpacing: 0.339,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _pinController,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF101828),
                                  letterSpacing: -0.15,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Enter 4-digit PIN",
                                  hintStyle: TextStyle(
                                    color: Color(0xFF99A1AF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8063FC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.439,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Secure Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 12,
                              color: Color(0xFF6A7282),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Secured by PIN authentication",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7282),
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
          ),
        ),
      ),
    );
  }
}
