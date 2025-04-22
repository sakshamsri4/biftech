import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopop/neopop.dart';
import 'package:video_player/video_player.dart';

/// {@template video_card}
/// A card widget that displays video information with playback functionality.
/// {@endtemplate}
class VideoCard extends StatefulWidget {
  /// {@macro video_card}
  const VideoCard({
    required this.video,
    required this.onTap,
    super.key,
  });

  /// The video model to display
  final VideoModel video;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.videoUrl != widget.video.videoUrl) {
      _disposeController();
      _initializeController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initializeController() async {
    if (widget.video.videoUrl.isEmpty) return;

    try {
      // Get the controller from the cubit if it exists
      final cubit = context.read<VideoFeedCubit>();
      final existingController = cubit.getControllerForVideo(widget.video.id);

      if (existingController != null) {
        // Use the existing controller
        if (mounted) {
          setState(() {
            _controller = existingController;
            _isPlaying = widget.video.isPlaying;
          });
        }
      } else {
        // Initialize the controller through the cubit
        await cubit.initializeVideoController(widget.video);

        // Get the initialized controller
        final controller = cubit.getControllerForVideo(widget.video.id);

        if (mounted && controller != null) {
          setState(() {
            _controller = controller;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing video controller: $e');
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isPlaying = false;
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    final cubit = context.read<VideoFeedCubit>();

    if (_isPlaying) {
      // Pause this video
      cubit.pauseVideo(widget.video.id);
    } else {
      // Play this video (will pause others)
      cubit.playVideo(widget.video.id);
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        child: NeoPopCard(
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player or thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Video player or thumbnail
                        if (_controller != null &&
                            _controller!.value.isInitialized)
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: VideoPlayer(_controller!),
                          )
                        else
                          CachedNetworkImage(
                            imageUrl: widget.video.thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),

                        // Play button overlay
                        if (!_isPlaying || _controller == null)
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),

                        // Duration overlay
                        if (widget.video.duration.isNotEmpty && !_isPlaying)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.video.duration,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  widget.video.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Creator and views
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.video.creator,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      '${_formatViews(widget.video.views)} views',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),

                // Participate button
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: widget.onTap,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Participate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formats the view count to a more readable format
  /// e.g. 1200 -> 1.2K, 1500000 -> 1.5M
  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }
}
