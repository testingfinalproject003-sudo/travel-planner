import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum AvatarSize { sm, md, lg }

class AppAvatar extends StatelessWidget {
  final String name;
  final AvatarSize size;
  final Color backgroundColor;
  final Color textColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.size = AvatarSize.md,
    this.backgroundColor = AppColors.primaryMuted,
    this.textColor = AppColors.primary,
  });

  String get initials {
    final tokens = name.trim().split(' ');
    String initial = '';
    if (tokens.isNotEmpty && tokens[0].isNotEmpty) {
      initial += tokens[0][0];
    }
    if (tokens.length > 1 && tokens[1].isNotEmpty) {
      initial += tokens[1][0];
    }
    return initial.toUpperCase();
  }

  double get radiusDimensions {
    switch (size) {
      case AvatarSize.sm: return 14;
      case AvatarSize.md: return 20;
      case AvatarSize.lg: return 28;
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return CircleAvatar(
      radius: radiusDimensions,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: radiusDimensions * 0.8,
        ),
      ),
    );
  }
}