import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../providers/map_provider.dart';
import '../../models/location_photo_model.dart';
import 'package:provider/provider.dart';

class LocationPhotosWidget extends StatefulWidget {
  final String locationName;

  const LocationPhotosWidget({
    super.key,
    required this.locationName,
  });

  @override
  State<LocationPhotosWidget> createState() => _LocationPhotosWidgetState();
}

class _LocationPhotosWidgetState extends State<LocationPhotosWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadLocationPhotos(widget.locationName);
    });
  }

  @override
  void didUpdateWidget(LocationPhotosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locationName != widget.locationName) {
      context.read<MapProvider>().loadLocationPhotos(widget.locationName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingPhotos) {
          return _buildShimmer();
        }

        if (provider.locationPhotos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                Icon(Icons.photo_camera, color: AppColors.textMuted.withValues(alpha:0.5), size: 32),
                const SizedBox(height: 8),
                Text(
                  'No photos found',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos of ${widget.locationName}',
                  style: AppTextStyles.sectionTitle,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full gallery
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.locationPhotos.length,
                itemBuilder: (context, index) {
                  final photo = provider.locationPhotos[index];
                  return _PhotoCard(photo: photo);
                },
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Photos via Unsplash',
                style: AppTextStyles.captionSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.shimmer,
            highlightColor: AppColors.white,
            child: Container(
              width: 120,
              height: 160,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.shimmer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final LocationPhotoModel photo;

  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open full screen gallery
      },
      child: Container(
        width: 120,
        height: 160,
        margin: const EdgeInsets.only(right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: CachedNetworkImage(
            imageUrl: photo.thumbUrl,
            fit: BoxFit.cover,
            width: 120,
            height: 160,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: AppColors.shimmer,
              highlightColor: AppColors.white,
              child: Container(color: AppColors.shimmer),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.primaryMuted,
              child: const Icon(Icons.broken_image, color: AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}