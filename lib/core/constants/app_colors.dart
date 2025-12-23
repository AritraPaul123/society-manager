import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary & Accents
  static const Color primaryPurple = Color(0xFFC27AFF);
  static const Color blobLavender = Color(0xFFDAB2FF);
  static const Color blobBlue = Color(0xFF8EC5FF);

  // Backgrounds
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(
    0x1AC27AFF,
  ); // rgba(194,122,255,0.1) -> 0.1 * 255 = ~25.5 -> 1A

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF3E8FF), // rgb(243, 232, 255)
      Color(0xFFFAF5FF), // rgb(250, 245, 255)
      Color(0xFFEFF6FF), // rgb(239, 246, 255)
    ],
    stops: [0.0, 0.5, 1.0],
    transform: GradientRotation(1.97), // 113.244deg approx
  );

  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF667EEA), // rgb(102, 126, 234)
      Color(0xFF764BA2), // rgb(118, 75, 162)
    ],
    transform: GradientRotation(1.75), // 100.408deg approx
  );

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.1)
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.1)
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -6,
    ),
  ];

  static const List<BoxShadow> roleCardShadow = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05) ~ 0.05
      offset: Offset(0, 2),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
}
