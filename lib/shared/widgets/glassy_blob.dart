import 'dart:ui';
import 'package:flutter/material.dart';

class GlassyBlob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double blurSigma;

  const GlassyBlob({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.blurSigma = 80.0, // Approximating blur-3xl
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width), // Pill/Circle shape
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
