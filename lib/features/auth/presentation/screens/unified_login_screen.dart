import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'package:society_man/core/services/biometric_service.dart';
import 'dart:io';
import 'package:society_man/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final UserRole _selectedRole = UserRole.guard;
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _showPassword = false;
  bool _isScanEnabled = false;
  bool _isScanning = false;
  bool _isLoginBlocked = false;
  int _bioAttempts = 0;

  @override
  void dispose() {
    _staffIdController.dispose();
    _passcodeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleCredentialChange() {
    setState(() {
      if (_selectedRole == UserRole.guard) {
        _isScanEnabled =
            _staffIdController.text.trim().isNotEmpty &&
            _passcodeController.text.trim().isNotEmpty;
      } else {
        _isScanEnabled =
            true; // For other roles, we'll handle validation differently
      }
    });
  }

  final BiometricService _biometricService = BiometricService();

  Future<void> _handleGuardLogin() async {
    setState(() => _isScanning = true);

    // Call real API
    // Mapping Staff ID to email for this demo backend
    final bool credentialsValid = await ApiService().login(
      'guard@society.com', // In production, this would be looked up by Staff ID
      _passcodeController.text,
    );

    if (!credentialsValid) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Staff ID or Passcode'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Now perform biometric authentication (Mandatory for Guard)
    bool isBioAvailable = await _biometricService.isBiometricAvailable();
    if (isBioAvailable) {
      bool authenticated = await _biometricService.authenticate(
        localizedReason: 'Please authenticate to login as Guard',
      );

      if (authenticated && mounted) {
        setState(() {
          _isScanning = false;
          _bioAttempts = 0;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_staff_id', _staffIdController.text);
        await prefs.setString('current_guard_id', _staffIdController.text);

        Navigator.pushReplacementNamed(context, AppRoutes.attendanceManagement);
      } else {
        setState(() {
          _isScanning = false;
          _bioAttempts++;
          if (_bioAttempts >= 3) {
            _isLoginBlocked = true;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLoginBlocked
                    ? 'Login blocked due to multiple failed attempts'
                    : 'Biometric authentication failed (Attempt $_bioAttempts/3)',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // For development/emulators without biometrics, we allow bypass only if explicitly stated,
      // but sticking to your rule: it is mandatory.
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric hardware required for Guard login'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handleAdminLogin() async {
    setState(() => _isScanning = true);

    bool credentialsValid = await ApiService().login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isScanning = false);

    if (!credentialsValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Admin Credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    }
  }

  Future<void> _handleResidentLogin() async {
    setState(() => _isScanning = true);

    // Call real API using the fixed test email for residents
    bool credentialsValid = await ApiService().login(
      'resident@society.com',
      _pinController.text, // PIN acts as password
    );

    setState(() => _isScanning = false);

    if (!credentialsValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid PIN'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.attendanceManagement);
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
            stops: [0.0, 0.5, 1.0], // approximated via check
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: double.infinity, // max-w-md (approx 28rem = 448px)
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

                  const SizedBox(height: 24),

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
                                  Icons.lock_outline_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            Text(
                              "${_selectedRole.name[0].toUpperCase()}${_selectedRole.name.substring(1)} Login",
                              style: const TextStyle(
                                fontSize: 22,
                                color: Color(0xFF101828),
                                height: 1.5, // 33px / 22px
                                letterSpacing: -0.258,
                              ),
                            ),
                            Text(
                              _selectedRole == UserRole.guard
                                  ? "Staff ID + Passcode + Face ID"
                                  : _selectedRole == UserRole.admin
                                  ? "Username + Password"
                                  : "App PIN",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6A7282),
                                height: 1.5, // 19.5px / 13px
                                letterSpacing: -0.076,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Authentication Fields based on role
                        _buildAuthFields(),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _getLoginAction(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8063FC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isScanning
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
                            Text(
                              _selectedRole == UserRole.guard
                                  ? "Secured by biometric authentication"
                                  : _selectedRole == UserRole.admin
                                  ? "Secured by admin authentication"
                                  : "Secured by PIN authentication",
                              style: const TextStyle(
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

  Widget _buildAuthFields() {
    switch (_selectedRole) {
      case UserRole.guard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staff ID Field
            const Text(
              "STAFF ID",
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
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _staffIdController,
                onChanged: (_) => _handleCredentialChange(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF101828),
                  letterSpacing: -0.15,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter Staff ID",
                  hintStyle: TextStyle(color: Color(0xFF99A1AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Passcode Field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Passcode",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                      letterSpacing: -0.076,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _passcodeController,
                      onChanged: (_) => _handleCredentialChange(),
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF101828),
                        letterSpacing: -0.15,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Enter Passcode",
                        hintStyle: TextStyle(color: Color(0xFF99A1AF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Biometric Section
            Container(
              padding: const EdgeInsets.only(
                top: 32,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    // inset simulation not natively supported easily on containers without custom painter
                    // effectively ignored in basic flutter container or mapped to outer shadow delicately
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Floating Badge
                  Positioned(
                    top: -42, // Adjusted relative to container padding
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Text(
                        "BIOMETRIC VERIFICATION",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5565),
                          letterSpacing: 0.339,
                        ),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      // Button Area
                      Center(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Blur Effect
                              AnimatedScale(
                                scale: _isScanEnabled ? 1.1 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _isScanEnabled
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFA995E8),
                                              Color(0xFFC8B8F5),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: !_isScanEnabled
                                        ? Colors.grey.withOpacity(0.2)
                                        : null,
                                  ),
                                ),
                              ),
                              if (_isScanEnabled)
                                Container(
                                  // Blur overlay hack since BackdropFilter clips
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(
                                      0.0,
                                    ), // placeholder
                                  ),
                                  // In flutter, blurring a shape without clipping child is tricky.
                                  // We will omit the blur filter and rely on the gradient/opacity for style
                                ),

                              // Main Circular Button
                              GestureDetector(
                                onTap: _isScanEnabled && !_isScanning
                                    ? _handleGuardLogin
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _isScanEnabled
                                          ? [
                                              const Color(0xFFE8E4F8),
                                              const Color(0xFFF0EDF9),
                                            ]
                                          : [
                                              const Color(0xFFF5F5F5),
                                              const Color(0xFFFAFAFA),
                                            ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon Circle
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 70,
                                        height: 70,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: _isScanEnabled
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFFA995E8),
                                                    Color(0xFFC8B8F5),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          color: !_isScanEnabled
                                              ? const Color(0xFFD1D5DB)
                                              : null, // gray-300
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              offset: const Offset(0, 4),
                                              blurRadius: 6,
                                              spreadRadius: -4,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              offset: const Offset(0, 10),
                                              blurRadius: 15,
                                              spreadRadius: -3,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CustomPaint(
                                            size: const Size(32, 32),
                                            painter: FaceInfoIconPainter(),
                                          ),
                                        ),
                                      ),

                                      // Texts
                                      Text(
                                        _isLoginBlocked
                                            ? "Login Blocked"
                                            : (_isScanning
                                                  ? "Verifying..."
                                                  : "Biometric Login"),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF101828),
                                          letterSpacing: -0.15,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isLoginBlocked
                                            ? "Contact admin to unlock"
                                            : "Authenticate to proceed",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF6A7282),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Live Scan Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: -1,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Live Face Scan Required",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF101828),
                                letterSpacing: -0.076,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Position your face within the frame",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case UserRole.admin:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Field
            const Text(
              "USERNAME",
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
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _usernameController,
                onChanged: (_) => _handleCredentialChange(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF101828),
                  letterSpacing: -0.15,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter Username",
                  hintStyle: TextStyle(color: Color(0xFF99A1AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password Field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                      letterSpacing: -0.076,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _passwordController,
                      onChanged: (_) => _handleCredentialChange(),
                      obscureText: !_showPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF101828),
                        letterSpacing: -0.15,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: const TextStyle(color: Color(0xFF99A1AF)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF6A7282),
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case UserRole.resident:
        return Column(
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
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                onChanged: (_) => _handleCredentialChange(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF101828),
                  letterSpacing: -0.15,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter 4-digit PIN",
                  hintStyle: TextStyle(color: Color(0xFF99A1AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  isDense: true,
                ),
              ),
            ),
          ],
        );
    }
  }

  VoidCallback? _getLoginAction() {
    if (_isScanning) return null;

    switch (_selectedRole) {
      case UserRole.guard:
        return _staffIdController.text.trim().isNotEmpty &&
                _passcodeController.text.trim().isNotEmpty
            ? _handleGuardLogin
            : null;
      case UserRole.admin:
        return _usernameController.text.trim().isNotEmpty &&
                _passwordController.text.trim().isNotEmpty
            ? _handleAdminLogin
            : null;
      case UserRole.resident:
        return _pinController.text.trim().isNotEmpty
            ? _handleResidentLogin
            : null;
      default:
        return null;
    }
  }
}

class FaceInfoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.66615
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Path 1
    path.moveTo(3.99922, 9.33154);
    path.lineTo(3.99922, 6.66539);
    path.cubicTo(3.99922, 5.95828, 4.28012, 5.28013, 4.78012, 4.78013);
    path.cubicTo(5.28012, 4.28013, 5.95826, 3.99924, 6.66537, 3.99924);
    path.lineTo(9.33152, 3.99924);

    // Path 2
    path.moveTo(22.6623, 3.99924);
    path.lineTo(25.3284, 3.99924);
    path.cubicTo(26.0355, 3.99924, 26.7137, 4.28013, 27.2137, 4.78013);
    path.cubicTo(27.7137, 5.28013, 27.9946, 5.95828, 27.9946, 6.66539);
    path.lineTo(27.9946, 9.33154);

    // Path 3
    path.moveTo(27.9946, 22.6623);
    path.lineTo(27.9946, 25.3284);
    path.cubicTo(27.9946, 26.0355, 27.7137, 26.7137, 27.2137, 27.2137);
    path.cubicTo(26.7137, 27.7137, 26.0355, 27.9946, 25.3284, 27.9946);
    path.lineTo(22.6623, 27.9946);

    // Path 4
    path.moveTo(9.33152, 27.9946);
    path.lineTo(6.66537, 27.9946);
    path.cubicTo(5.95826, 27.9946, 5.28012, 27.7137, 4.78012, 27.2137);
    path.cubicTo(4.28012, 26.7137, 3.99922, 26.0355, 3.99922, 25.3284);
    path.lineTo(3.99922, 22.6623);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
