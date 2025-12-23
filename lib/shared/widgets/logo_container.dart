import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

class LogoContainer extends StatelessWidget {
  final Widget child;

  const LogoContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.logoContainerSize,
      height: AppDimens.logoContainerSize,
      padding: const EdgeInsets.all(AppDimens.p12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.r16)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Center(child: child),
    );
  }
}
