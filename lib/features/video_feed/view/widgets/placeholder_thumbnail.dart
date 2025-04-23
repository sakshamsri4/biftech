import 'package:flutter/material.dart';

/// A placeholder widget for video thumbnails
class PlaceholderThumbnail extends StatelessWidget {
  /// Constructor
  const PlaceholderThumbnail({
    this.width = 100,
    this.height = 60,
    super.key,
  });

  /// Width of the thumbnail
  final double width;

  /// Height of the thumbnail
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.video_library,
          color: Colors.white70,
          size: 32,
        ),
      ),
    );
  }
}
