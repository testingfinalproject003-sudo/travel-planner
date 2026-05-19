import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

enum ButtonVariant { primary, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext buildContext) {
    Widget currentButton;
    final content = isLoading
        ? const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.white), strokeWidth: 2),
    )
        : Text(label);

    switch (variant) {
      case ButtonVariant.primary:
        currentButton = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
        break;
      case ButtonVariant.outline:
        currentButton = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
          ),
          child: content,
        );
        break;
      case ButtonVariant.ghost:
        currentButton = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: content,
        );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: currentButton) : currentButton;
  }
}