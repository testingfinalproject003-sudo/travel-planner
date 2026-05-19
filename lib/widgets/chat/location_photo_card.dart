import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../models/location_photo_model.dart';

class LocationPhotoCard extends StatelessWidget {
  final LocationPhotoModel photo;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const LocationPhotoCard({
    super.key,
    required this.photo,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: CachedNetworkImage(
          imageUrl: photo.url,
          fit: BoxFit.cover,
          width: width,
          height: height,
          placeholder: (context, url) => Container(
            color: AppColors.shimmer,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.primaryMuted,
            child: const Icon(Icons.broken_image, color: AppColors.textMuted, size: 32),
          ),
        ),
      ),
    );
  }
}