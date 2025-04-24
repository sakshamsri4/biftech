import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingPlaceholder extends StatelessWidget {
  const ShimmerLoadingPlaceholder({
    required this.width,
    required this.height,
    super.key,
    this.shapeBorder = const RoundedRectangleBorder(),
  });
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!, // Darker base for dark theme
      highlightColor: Colors.grey[800]!, // Subtle highlight
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[850],
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class VideoCardShimmerPlaceholder extends StatelessWidget {
  const VideoCardShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // Dark card background
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Placeholder
            ShimmerLoadingPlaceholder(
              width: double.infinity,
              height: 200, // Adjust height as needed (e.g., based on 16:9)
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            // Title Placeholder
            const ShimmerLoadingPlaceholder(width: double.infinity, height: 20),
            const SizedBox(height: 8),
            const ShimmerLoadingPlaceholder(width: 200, height: 20),
            const SizedBox(height: 12),
            // Creator/Views Placeholder
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoadingPlaceholder(width: 100, height: 16),
                ShimmerLoadingPlaceholder(width: 80, height: 16),
              ],
            ),
            const SizedBox(height: 16),
            // Button Placeholder
            const ShimmerLoadingPlaceholder(
              width: double.infinity,
              height: 48,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoListShimmer extends StatelessWidget {
  const VideoListShimmer({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const VideoCardShimmerPlaceholder(),
    );
  }
}
