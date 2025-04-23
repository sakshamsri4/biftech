import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/widgets/placeholder_thumbnail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.onDelete,
    super.key,
  });

  /// The video model to display
  final VideoModel video;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Callback when the delete button is tapped
  /// If null, the delete option will not be shown
  final Future<bool> Function(String videoId)? onDelete;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isLoading = false;
  bool _isNetworkError = false;

  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid issues with widget tree building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeController();
      }
    });
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id) {
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
    try {
      // Get the controller from the cubit
      final cubit = context.read<VideoFeedCubit>();
      _controller = cubit.getControllerForVideo(widget.video.id);

      if (_controller != null && _controller!.value.isInitialized) {
        if (mounted) {
          setState(() {
            // Controller is initialized
            _hasError = false;
            _isLoading = false;
          });

          // Add listener for playback state
          _controller!.addListener(_videoListener);
        }
      } else if (_controller == null || !_controller!.value.isInitialized) {
        // If controller doesn't exist or isn't initialized,
        // try to initialize it
        try {
          if (mounted) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          }

          await cubit.initializeVideoController(widget.video);

          // Check if widget is still mounted after async operation
          if (!mounted) return;

          // Get the controller again after initialization
          _controller = cubit.getControllerForVideo(widget.video.id);

          if (_controller != null && _controller!.value.isInitialized) {
            setState(() {
              // Controller is initialized
              _isLoading = false;
              _hasError = false;
            });

            // Add listener for playback state
            _controller!.addListener(_videoListener);
            debugPrint(
              'Successfully initialized controller for video: '
              '${widget.video.id}',
            );
          } else {
            // Controller exists but isn't initialized properly
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        } catch (e) {
          // Log error but don't show to user unless they try to play
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoCard._initializeController.initialize',
          );
          debugPrint(
            'Failed to initialize controller for video: '
            '${widget.video.id}: $e',
          );

          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        }
      }
    } catch (e) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        context: 'VideoCard._initializeController',
      );
      debugPrint('Error in _initializeController: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final isPlaying = _controller!.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    }
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      // Note: We don't dispose
      // the controller here since it's managed by the cubit
      _controller = null;
    }
  }

  // Removed unused _formatDuration method

  /// Retry initializing the video controller
  Future<void> _retryVideoInitialization() async {
    if (!mounted) return;

    // Store context references before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final cubit = context.read<VideoFeedCubit>();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _isNetworkError = false;
    });

    try {
      // Try to initialize the controller
      await cubit.initializeVideoController(widget.video);

      if (!mounted) return;

      // Get the controller after initialization
      _controller = cubit.getControllerForVideo(widget.video.id);

      if (_controller != null && _controller!.value.isInitialized) {
        setState(() {
          // Controller is initialized
          _isLoading = false;
          _hasError = false;
          _isNetworkError = false;
        });

        // Add listener for playback state
        _controller!.addListener(_videoListener);
        debugPrint(
          'Successfully reinitialized controller for video: '
          '${widget.video.id}',
        );
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isNetworkError = false;
        });

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to load video. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Log error
      ErrorLoggingService.instance.logError(
        e,
        context: 'VideoCard._retryVideoInitialization',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _isNetworkError = false;
      });

      const errorMessage = 'Failed to load video. Please try again later.';

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Toggle play/pause state of the video
  Future<void> _togglePlayPause() async {
    // If we have an error, try to reinitialize the controller
    if (_hasError) {
      await _retryVideoInitialization();
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      if (!mounted) return;

      // Store context references before async operations
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final cubit = context.read<VideoFeedCubit>();

      // No need to check network connectivity as we're only using local files

      if (!mounted) return;

      // If controller is not initialized, try to initialize it
      setState(() {
        _isLoading = true;
        _hasError = false;
        _isNetworkError = false;
      });

      try {
        // Try to initialize the controller
        await cubit.initializeVideoController(widget.video);

        if (!mounted) return;

        // After initialization, get the controller again
        _controller = cubit.getControllerForVideo(widget.video.id);
        if (_controller != null && _controller!.value.isInitialized) {
          setState(() {
            // Controller is initialized
            _isLoading = false;
            _hasError = false;
            _isNetworkError = false;
            // Add listener for playback state
            _controller!.addListener(_videoListener);
            // Play the video
            _isPlaying = true;
          });

          // Pause all other videos
          await cubit.pauseAllVideos();
          if (mounted && _controller != null) {
            await _controller!.play();
          }
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _isNetworkError = false;
          });

          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to play video. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Log the error
        ErrorLoggingService.instance.logError(
          e,
          context: 'VideoCard._togglePlayPause.initializeController',
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _hasError = true;
          _isNetworkError = false;
        });

        const errorMessage = 'Failed to play video. Please try again.';

        // Show a snackbar with the error
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        // Pause all other videos first
        context.read<VideoFeedCubit>().pauseAllVideos();
        // Then play this one
        _controller!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: NeoPopCard(
          color: const Color(0xFF121212),
          depth: 10,
          borderColor: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player or thumbnail with NeoPOP styling
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color:
                            Color(0x80000000), // Colors.black with 50% opacity
                        blurRadius: 15,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Video player or thumbnail
                          if (_controller != null &&
                              _controller!.value.isInitialized)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _togglePlayPause();
                              },
                              child: VideoPlayer(_controller!),
                            )
                          else if (_isLoading)
                            // Loading state
                            const ColoredBox(
                              color: Color(0xFF1E1E1E),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6C63FF),
                                  ),
                                ),
                              ),
                            )
                          else if (_hasError)
                            // Error state with retry button
                            ColoredBox(
                              color: const Color(0xFF1E1E1E),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isNetworkError
                                          ? Icons.wifi_off
                                          : Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isNetworkError
                                          ? 'No internet connection'
                                          : 'Failed to load video',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isNetworkError
                                          ? 'Please check your network settings'
                                          : 'Please try again',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    NeoPopButton(
                                      color: const Color(0xFF6C63FF),
                                      onTapUp: _retryVideoInitialization,
                                      onTapDown: HapticFeedback.lightImpact,
                                      parentColor: const Color(0xFF1E1E1E),
                                      depth: 8,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'RETRY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // Thumbnail
                            widget.video.thumbnailUrl.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: widget.video.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const ColoredBox(
                                      color: Color(0xFF1E1E1E),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF6C63FF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      // Log the error
                                      ErrorLoggingService.instance.logError(
                                        error,
                                        context: 'VideoCard.thumbnail',
                                      );
                                      return const PlaceholderThumbnail(
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    },
                                  )
                                : const PlaceholderThumbnail(
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),

                          // Play button overlay with NeoPOP styling
                          if ((!_isPlaying || _controller == null) &&
                              !_isLoading &&
                              !_hasError)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _togglePlayPause();
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6C63FF),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      // Colors.black with 50% opacity
                                      color: Color(0x80000000),
                                      blurRadius: 10,
                                      offset: Offset(3, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),

                          // Duration overlay with NeoPOP styling
                          if (widget.video.duration.isNotEmpty && !_isPlaying)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      // Colors.black with 50% opacity
                                      color: Color(0x80000000),
                                      blurRadius: 5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.video.duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title with CRED-style typography
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Creator and views with CRED-style typography
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.video.creator,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6C63FF),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_formatViews(widget.video.views)} views',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action buttons with NeoPOP styling
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Participate button
                    Expanded(
                      child: NeoPopButton(
                        color: const Color(0xFF6C63FF),
                        onTapUp: () {
                          HapticFeedback.mediumImpact();
                          widget.onTap();
                        },
                        onTapDown: HapticFeedback.lightImpact,
                        parentColor: const Color(0xFF121212),
                        depth: 8,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'PARTICIPATE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Delete button (if onDelete callback is provided)
                    if (widget.onDelete != null) ...[
                      const SizedBox(width: 12),
                      NeoPopButton(
                        color: Colors.red,
                        onTapUp: () {
                          HapticFeedback.mediumImpact();
                          _showDeleteConfirmation(context);
                        },
                        onTapDown: HapticFeedback.lightImpact,
                        parentColor: const Color(0xFF121212),
                        depth: 8,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ],
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

  /// Shows a confirmation dialog before deleting a video
  void _showDeleteConfirmation(BuildContext context) {
    // Store the current context and scaffold messenger
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Video',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this video? '
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          NeoPopButton(
            color: Colors.red,
            onTapUp: () {
              HapticFeedback.mediumImpact();
              Navigator.of(dialogContext).pop(true);
            },
            onTapDown: HapticFeedback.lightImpact,
            parentColor: const Color(0xFF1E1E1E),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'DELETE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      // Use ?? to convert null to false
      if (confirmed ?? false) {
        if (mounted && widget.onDelete != null) {
          // Show loading indicator
          scaffoldMessenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Deleting video...'),
                duration: Duration(seconds: 1),
              ),
            );

          // Call the delete function and handle the result
          _performDelete(scaffoldMessenger);
        }
      }
    });
  }

  /// Performs the actual deletion after confirmation
  Future<void> _performDelete(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      // Call the delete callback
      final success = await widget.onDelete!(widget.video.id);

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      // Show success or error message
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Video deleted successfully' : 'Failed to delete video',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
    } catch (e) {
      // Handle any errors
      if (!mounted) return;

      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting the video'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }
}
