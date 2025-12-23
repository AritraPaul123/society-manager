import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/face_scanner_service.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();
  bool _isScanEnabled = false;
  File? _capturedFace;
  bool _isScanning = false;
  int _faceIdAttempts = 0;
  bool _isLoginBlocked = false;

  void _handleCredentialChange() {
    setState(() {
      _isScanEnabled =
          _staffIdController.text.trim().isNotEmpty &&
          _passcodeController.text.trim().isNotEmpty;
    });
  }

  Future<bool> _authenticateStaff(String staffId, String passcode) async {
    // This is a placeholder implementation
    // In a real app, you would authenticate against a backend
    // For now, we'll simulate authentication
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real implementation, verify credentials against stored data
    // For demo, we'll just check if the passcode is not empty
    return passcode.isNotEmpty && staffId.isNotEmpty;
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _passcodeController.dispose();
    super.dispose();
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
                            const Text(
                              "Staff Login",
                              style: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF101828),
                                height: 1.5, // 33px / 22px
                                letterSpacing: -0.258,
                              ),
                            ),
                            const Text(
                              "Secure biometric authentication",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6A7282),
                                height: 1.5, // 19.5px / 13px
                                letterSpacing: -0.076,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Input Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "STAFF CREDENTIALS",
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
                                controller: _staffIdController,
                                onChanged: (_) => _handleCredentialChange(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF101828),
                                  letterSpacing: -0.15,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Enter Staff ID",
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
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
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
                                top:
                                    -42, // Adjusted relative to container padding
                                child: Container(
                                  height: 20,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
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
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: _isScanEnabled
                                                    ? const LinearGradient(
                                                        colors: [
                                                          Color(0xFFA995E8),
                                                          Color(0xFFC8B8F5),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      )
                                                    : null,
                                                color: !_isScanEnabled
                                                    ? Colors.grey.withOpacity(
                                                        0.2,
                                                      )
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
                                            onTap:
                                                _isScanEnabled &&
                                                    !_isScanning &&
                                                    !_isLoginBlocked
                                                ? () async {
                                                    setState(() {
                                                      _isScanning = true;
                                                    });

                                                    try {
                                                      // First authenticate the staff credentials
                                                      bool credentialsValid =
                                                          await _authenticateStaff(
                                                            _staffIdController
                                                                .text,
                                                            _passcodeController
                                                                .text,
                                                          );

                                                      if (!credentialsValid) {
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Invalid credentials',
                                                              ),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                        }
                                                        setState(() {
                                                          _isScanning = false;
                                                        });
                                                        return;
                                                      }

                                                      final File? faceImage =
                                                          await FaceScannerService.scanFace(
                                                            context,
                                                          );
                                                      if (faceImage != null &&
                                                          mounted) {
                                                        setState(() {
                                                          _capturedFace =
                                                              faceImage;
                                                          _isScanning = false;
                                                        });

                                                        // In production: verify face against stored face
                                                        bool faceVerified =
                                                            await FaceScannerService.verifyFaceForUser(
                                                              _staffIdController
                                                                  .text,
                                                              faceImage,
                                                            );

                                                        if (faceVerified &&
                                                            mounted) {
                                                          // Create attendance record
                                                          final attendanceRecord =
                                                              AttendanceRecord(
                                                                guardId:
                                                                    'GRD-${_staffIdController.text}',
                                                                staffId:
                                                                    _staffIdController
                                                                        .text,
                                                                checkInTime:
                                                                    DateTime.now(),
                                                                location:
                                                                    'Main Gate',
                                                                status:
                                                                    AttendanceStatus
                                                                        .onDuty,
                                                                checkInFaceImage:
                                                                    faceImage,
                                                              );

                                                          await LocalStorageService.saveAttendanceRecord(
                                                            attendanceRecord,
                                                          );

                                                          if (mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Attendance marked! Status: On Duty',
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                duration:
                                                                    Duration(
                                                                      seconds:
                                                                          2,
                                                                    ),
                                                              ),
                                                            );

                                                            // Navigate to guard patrol dashboard
                                                            await Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                            );

                                                            if (mounted) {
                                                              Navigator.pushReplacementNamed(
                                                                context,
                                                                AppRoutes
                                                                    .guardPatrolDashboard,
                                                              );
                                                            }
                                                          }
                                                        } else {
                                                          // Face verification FAILED
                                                          setState(() {
                                                            _faceIdAttempts++;
                                                            if (_faceIdAttempts >=
                                                                3) {
                                                              _isLoginBlocked =
                                                                  true;
                                                            }
                                                          });

                                                          if (mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  _isLoginBlocked
                                                                      ? 'Login BLOCKED! Face ID failed 3 times. Contact admin.'
                                                                      : 'Face verification failed. Attempt ${_faceIdAttempts}/3',
                                                                ),
                                                                backgroundColor:
                                                                    Colors.red,
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          3,
                                                                    ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          _isScanning = false;
                                                        });
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _isScanning = false;
                                                        });
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Error: ${e.toString()}',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                : null,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              width: 220,
                                              height: 220,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: _isScanEnabled
                                                      ? [
                                                          const Color(
                                                            0xFFE8E4F8,
                                                          ),
                                                          const Color(
                                                            0xFFF0EDF9,
                                                          ),
                                                        ]
                                                      : [
                                                          const Color(
                                                            0xFFF5F5F5,
                                                          ),
                                                          const Color(
                                                            0xFFFAFAFA,
                                                          ),
                                                        ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // Icon Circle
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    width: 70,
                                                    height: 70,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: _isScanEnabled
                                                          ? const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFFA995E8,
                                                                ),
                                                                Color(
                                                                  0xFFC8B8F5,
                                                                ),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            )
                                                          : null,
                                                      color: !_isScanEnabled
                                                          ? const Color(
                                                              0xFFD1D5DB,
                                                            )
                                                          : null, // gray-300
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                          blurRadius: 6,
                                                          spreadRadius: -4,
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          offset: const Offset(
                                                            0,
                                                            10,
                                                          ),
                                                          blurRadius: 15,
                                                          spreadRadius: -3,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: CustomPaint(
                                                        size: const Size(
                                                          32,
                                                          32,
                                                        ),
                                                        painter:
                                                            FaceInfoIconPainter(),
                                                      ),
                                                    ),
                                                  ),

                                                  // Texts
                                                  Text(
                                                    _isLoginBlocked
                                                        ? "Login Blocked"
                                                        : (_isScanning
                                                              ? "Scanning..."
                                                              : "Start Face Scan"),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF101828),
                                                      letterSpacing: -0.15,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _isLoginBlocked
                                                        ? "Contact admin to unlock"
                                                        : "Enter credentials first",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              "Secured by biometric authentication",
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
