import 'package:flutter/material.dart';
import 'package:society_man/core/routes/app_routes.dart';

import 'dart:ui' as ui;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _showPassword = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    debugPrint(
      "Login attempt: ${_usernameController.text}, ${_passwordController.text}",
    );
    // Navigate to admin dashboard
    Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive positioning if needed,
    // but React code used % offsets which we can replicate with Align/Positioned.

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C6FDC),
                  Color(0xFF8B7AE5),
                  Color(0xFFB891E8),
                ],
              ),
            ),
          ),

          // Decorative Floating Dots
          // "left: '80%', top: '51%'" -> Align(alignment: FractionalOffset(0.8, 0.51)) or Positioned
          // We'll use a wrapper for brevity
          ..._buildFloatingDots(),

          // Blur Effects (Blobs)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 192, // 48 * 4
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple[300]!.withOpacity(0.27),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 64,
                  sigmaY: 64,
                ), // Using separate method to avoid clutter
                child: const SizedBox(),
              ),
            ),
          ),

          // We can't easily blur just the background of a shaped container without ClipRect
          // A simpler flutter approach for "blurred blob" is a Container with a BoxShadow/Gradient and a highly blurred Mask
          // OR: Just a Container with the color and a generic ImageFilter.blur wrapper?
          // Actually, standard Flutter `ImageFilter.blur` applies to child or backdrop.
          // For a "glowing orb", a Container with BoxShadow is often best.
          // Let's use the simplest: Container with radial gradient or simple color + Blur.
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: -40,
            child: const _BlurredBlob(
              width: 192,
              height: 192,
              color: Color(0x45BA68C8), // purple-300 approx with opacity
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: -40,
            child: const _BlurredBlob(
              width: 160,
              height: 160,
              color: Color(0x3ABA68C8), // purple-400 approx
            ),
          ),

          // Top-Left Logo (Absolute Positioned to stay 'upwards')
          Positioned(
            top: 40,
            left: 20,
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

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo (Moved to absolute Positioned to stay 'upwards')
                    // Removed from Column flow to allow absolute positioning in the parent Stack
                    const SizedBox(
                      height: 20,
                    ), // Placeholder to keep spacing for the absolute logo if needed, or just let card stay centered
                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 25),
                            blurRadius: 50,
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Lock Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF8B7AE5), Color(0xFF9F8FEC)],
                              ),
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
                            child: Center(
                              child: CustomPaint(
                                size: const Size(32, 32),
                                painter: AdminLockIconPainter(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "Admin Login",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0A0A0A),
                              letterSpacing: -0.312,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Username
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Username",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF364153),
                                  letterSpacing: -0.312,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _usernameController,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0A0A0A),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your username",
                                  hintStyle: TextStyle(
                                    color: const Color(
                                      0xFF0A0A0A,
                                    ).withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFA78BFA),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Password
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF364153),
                                  letterSpacing: -0.312,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0A0A0A),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter your password",
                                  hintStyle: TextStyle(
                                    color: const Color(
                                      0xFF0A0A0A,
                                    ).withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFA78BFA),
                                      width: 2,
                                    ),
                                  ),
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
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B7280),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
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

                          // Footer
                          const Text(
                            "Secure access to your home",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6A7282),
                              letterSpacing: -0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingDots() {
    final dots = [
      (0.80, 0.51, 0.20),
      (0.32, 0.64, 0.46),
      (0.61, 0.33, 0.40),
      (0.95, 0.12, 0.21), // right 0% approx
      (0.83, 0.58, 0.25),
      (0.54, 0.0, 0.28), // top -1%
      (0.15, 0.71, 0.33),
      (0.72, 0.61, 0.36),
      (0.11, 0.60, 0.38),
      (0.20, 0.39, 0.40),
      (0.80, 0.43, 0.40),
      (0.88, 0.28, 0.44),
    ];

    return dots
        .map(
          (d) => Positioned(
            left: MediaQuery.of(context).size.width * d.$1,
            top: MediaQuery.of(context).size.height * d.$2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(d.$3),
              ),
            ),
          ),
        )
        .toList();
  }
}

class _BlurredBlob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _BlurredBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 64, spreadRadius: 32)],
      ),
    );
  }
}

// Painters

class AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // scale to fit 48x48
    final scale = size.width / 48;
    canvas.scale(scale);

    final p1 = Path();
    p1.moveTo(24, 4);
    p1.lineTo(8, 14);
    p1.lineTo(8, 28);
    p1.cubicTo(8, 35.732, 15.163, 42.456, 24, 44);
    p1.cubicTo(32.837, 42.456, 40, 35.732, 40, 28);
    p1.lineTo(40, 14);
    p1.lineTo(24, 4);
    p1.close();

    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B7AE5), Color(0xFF7C6FDC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, 48, 48))
      ..style = PaintingStyle.fill;

    // Stroke
    final paintStroke = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9F8FEC), Color(0xFF8B7AE5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, 48, 48))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(p1, paint1);
    canvas.drawPath(p1, paintStroke);

    // Inner White Paths
    final paintWhite = Paint()..color = Colors.white;

    final p2 = Path();
    p2.moveTo(24, 18);
    p2.cubicTo(21.791, 18, 20, 19.791, 20, 22);
    p2.cubicTo(20, 24.209, 21.791, 26, 24, 26);
    p2.cubicTo(26.209, 26, 28, 24.209, 28, 22);
    p2.cubicTo(28, 19.791, 26.209, 18, 24, 18);
    p2.close();
    canvas.drawPath(p2, paintWhite);

    final p3 = Path();
    p3.moveTo(18, 32);
    p3.cubicTo(18, 29.791, 20.686, 28, 24, 28);
    p3.cubicTo(27.314, 28, 30, 29.791, 30, 32);
    p3.lineTo(30, 34);
    p3.lineTo(18, 34);
    p3.lineTo(18, 32);
    p3.close();
    canvas.drawPath(p3, paintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AdminLockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32;
    canvas.scale(scale);

    final paintStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.66563
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p1 = Path();
    p1.moveTo(25.3235, 14.6609);
    p1.lineTo(6.66411, 14.6609);
    p1.cubicTo(5.19192, 14.6609, 3.99847, 15.8544, 3.99847, 17.3266);
    p1.lineTo(3.99847, 26.6563);
    p1.cubicTo(3.99847, 28.1285, 5.19192, 29.3219, 6.66411, 29.3219);
    p1.lineTo(25.3235, 29.3219);
    p1.cubicTo(26.7957, 29.3219, 27.9892, 28.1285, 27.9892, 26.6563);
    p1.lineTo(27.9892, 17.3266);
    p1.cubicTo(27.9892, 15.8544, 26.7957, 14.6609, 25.3235, 14.6609);
    p1.close();
    canvas.drawPath(p1, paintStroke);

    final p2 = Path();
    p2.moveTo(9.32971, 14.661);
    p2.lineTo(9.32971, 9.3297);
    p2.cubicTo(9.32971, 7.56228, 10.0319, 5.86724, 11.2816, 4.61748);
    p2.cubicTo(12.5314, 3.36772, 14.2263, 2.66562, 15.9938, 2.66562);
    p2.cubicTo(17.7613, 2.66562, 19.4562, 3.36772, 20.706, 4.61748);
    p2.cubicTo(21.9557, 5.86724, 22.6579, 7.56228, 22.6579, 9.3297);
    p2.lineTo(22.6579, 14.661);
    canvas.drawPath(p2, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
