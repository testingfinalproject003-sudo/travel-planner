import 'package:flutter/material.dart';
import '../../widgets/explore/place_image_carousel.dart';
import '../../widgets/common/custom_button.dart';

class PlaceDetailScreen extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String whyFamous;
  final double rating;
  final List<String> imageUrls;
  final String distanceText;

  const PlaceDetailScreen({
    super.key,
    required this.title,
    required this.location,
    required this.description,
    required this.whyFamous,
    required this.rating,
    required this.imageUrls,
    required this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xffd99379),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: PlaceImageCarousel(imageUrls: imageUrls),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2d2d2d),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Color(0xffd99379)),
                                const SizedBox(width: 4),
                                Text(location, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffd99379).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Color(0xffd99379)),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffd99379),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xfffafafa),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Approximately $distanceText away from you",
                          style: const TextStyle(fontSize: 13, color: Color(0xff616161)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "About this destination",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 15, color: Color(0xff616161), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "✨ Why it's famous",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffd99379).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffd99379).withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      whyFamous,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff2d2d2d),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Plan Trip Here",
                      onPressed: () {
                        // Triggers state navigation block to pre-populate create_trip_screen
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}