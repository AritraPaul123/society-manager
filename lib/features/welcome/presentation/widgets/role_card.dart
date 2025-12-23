import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.roleCardHeight,
      margin: const EdgeInsets.only(bottom: AppDimens.p16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.r20),
        boxShadow: AppColors.roleCardShadow,
        border: Border.all(
          // Simulating the subtle border from Figma
          color: isSelected ? AppColors.primaryPurple : AppColors.glassBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.r20),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.p16),
            child: Row(
              children: [
                if (icon != null) ...[
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: AppDimens.p16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryPurple,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
