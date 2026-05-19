import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class AppLoader extends StatelessWidget {
  final String? label;

  const AppLoader({super.key, this.label});

  @override
  Widget build(BuildContext StatelessWidgetContext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (label != null) ...[
            const SizedBox(height: AppDimensions.md),
            Text(label!, style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ]
        ],
      ),
    );
  }
}