import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Note: Figma showed a simple button but with gradient. 
    // We will use a Container decoration for the gradient and Material for ink splash.
    return Container(
      height: 48, // Standard touch target
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple, // Fallback
        // Assuming a solid purple based on "Button" in metadata, or we can use gradient if specs say so.
        // The metadata didn't explicitly show button gradient, but the theme implied it. 
        // We'll stick to the primary purple for now as it's safe.
        borderRadius: BorderRadius.circular(AppDimens.r16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimens.r16),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
