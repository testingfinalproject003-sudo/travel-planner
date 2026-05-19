import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textMain, letterSpacing: -0.5);
  static const TextStyle heading2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain, letterSpacing: -0.3);
  static const TextStyle heading3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMain);
  static const TextStyle body     = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMain, height: 1.5);
  static const TextStyle small    = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted);
  static const TextStyle label    = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.6);
  static const TextStyle button   = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white);
  static const TextStyle whiteBody = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.white);
  static const TextStyle whiteMuted = TextStyle(fontSize: 13, color: Color(0xAAFFFFFF));
}