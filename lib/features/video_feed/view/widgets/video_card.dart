import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/widgets/placeholder_thumbnail.dart';
import 'package:biftech/features/video_feed/view/widgets/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

/// {@template video_card}
/// A card widget that displays video information with playback functionality.
/// Redesigned for CRED aesthetics.
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

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isLoading = true;
  bool _isNetworkError = false;
  bool _showControls = false;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsOpacity;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controlsOpacity = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );

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
      setState(() {
        _isPlaying = false;
        _hasError = false;
        _isLoading = true;
        _isNetworkError = false;
        _showControls = false;
        _controlsAnimationController.reset();
      });
      _initializeController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      final cubit = context.read<VideoFeedCubit>();
      _controller = cubit.getControllerForVideo(widget.video.id);

      if (_controller != null && _controller!.value.isInitialized) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
          _controller!.addListener(_videoListener);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });
        }
        try {
          await cubit.initializeVideoController(widget.video);
          if (!mounted) return;
          _controller = cubit.getControllerForVideo(widget.video.id);

          if (_controller != null && _controller!.value.isInitialized) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
            _controller!.addListener(_videoListener);
            debugPrint(
                'Successfully initialized controller for video: ${widget.video.id}');
          } else {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          }
        } catch (e) {
          ErrorLoggingService.instance.logError(e,
              context: 'VideoCard._initializeController.initialize');
          debugPrint(
              'Failed to initialize controller for video: ${widget.video.id}: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        }
      }
    } catch (e) {
      ErrorLoggingService.instance
          .logError(e, context: 'VideoCard._initializeController');
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
      final position = _controller!.value.position;
      final duration = _controller!.value.duration;

      if (isPlaying && position >= duration && duration > Duration.zero) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _controller?.seekTo(Duration.zero);
            _controller?.pause();
            _showControls = true;
            _controlsAnimationController.forward();
          });
        }
      } else if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
          if (_isPlaying) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _isPlaying) {
                setState(() {
                  _showControls = false;
                  _controlsAnimationController.reverse();
                });
              }
            });
          } else {
            setState(() {
              _showControls = true;
              _controlsAnimationController.forward();
            });
          }
        });
      }
    }
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller = null;
    }
  }

  Future<void> _retryVideoInitialization() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final cubit = context.read<VideoFeedCubit>();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _isNetworkError = false;
    });

    try {
      await cubit.initializeVideoController(widget.video);
      if (!mounted) return;
      _controller = cubit.getControllerForVideo(widget.video.id);

      if (_controller != null && _controller!.value.isInitialized) {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _isNetworkError = false;
        });
        _controller!.addListener(_videoListener);
        debugPrint(
            'Successfully reinitialized controller for video: ${widget.video.id}');
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isNetworkError = false;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to load video. Please try again later.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ErrorLoggingService.instance
          .logError(e, context: 'VideoCard._retryVideoInitialization');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isNetworkError = false;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to load video. Please try again later.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    HapticFeedback.selectionClick();

    if (_hasError) {
      await _retryVideoInitialization();
      return;
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final cubit = context.read<VideoFeedCubit>();
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _hasError = false;
        _isNetworkError = false;
      });

      try {
        await cubit.initializeVideoController(widget.video);
        if (!mounted) return;
        _controller = cubit.getControllerForVideo(widget.video.id);

        if (_controller != null && _controller!.value.isInitialized) {
          setState(() {
            _isLoading = false;
            _hasError = false;
            _isNetworkError = false;
            _isPlaying = true;
            _showControls = true;
          });
          _controller!.addListener(_videoListener);
          _controlsAnimationController.forward();

          await cubit.pauseAllVideos();
          if (mounted && _controller != null) {
            await _controller!.play();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _isPlaying) {
                setState(() {
                  _showControls = false;
                  _controlsAnimationController.reverse();
                });
              }
            });
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
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        ErrorLoggingService.instance.logError(e,
            context: 'VideoCard._togglePlayPause.initializeController');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isNetworkError = false;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to play video. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
        _showControls = true;
        _controlsAnimationController.forward();
      } else {
        context.read<VideoFeedCubit>().pauseAllVideos().then((_) {
          if (mounted && _controller != null) {
            _controller!.play();
            _isPlaying = true;
            _showControls = true;
            _controlsAnimationController.forward();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _isPlaying) {
                setState(() {
                  _showControls = false;
                  _controlsAnimationController.reverse();
                });
              }
            });
          }
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        !_isLoading &&
        !_hasError) {
      setState(() {
        _showControls = !_showControls;
        if (_showControls) {
          _controlsAnimationController.forward();
          if (_isPlaying) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _isPlaying && _showControls) {
                setState(() {
                  _showControls = false;
                  _controlsAnimationController.reverse();
                });
              }
            });
          }
        } else {
          _controlsAnimationController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const purpleAccent = Color(0xFF9B51E0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isLoading)
                      const VideoCardShimmerPlaceholder()
                    else if (_hasError)
                      _buildErrorState(purpleAccent)
                    else if (_controller != null &&
                        _controller!.value.isInitialized)
                      GestureDetector(
                        onTap: _toggleControlsVisibility,
                        child: VideoPlayer(_controller!),
                      )
                    else
                      _buildThumbnail(),
                    if (!_isLoading &&
                        !_hasError &&
                        _controller != null &&
                        _controller!.value.isInitialized)
                      GestureDetector(
                        onTap: _toggleControlsVisibility,
                        child: FadeTransition(
                          opacity: _controlsOpacity,
                          child: ColoredBox(
                            color: Colors.black.withOpacity(0.4),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      purpleAccent.withOpacity(0.8),
                                  padding: const EdgeInsets.all(10),
                                ),
                                onPressed: _togglePlayPause,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!_isLoading &&
                        !_hasError &&
                        !_isPlaying &&
                        !_showControls &&
                        (_controller == null ||
                            !_controller!.value.isInitialized))
                      _buildInitialPlayButton(purpleAccent),
                    if (widget.video.duration.isNotEmpty &&
                        !_isPlaying &&
                        !_isLoading &&
                        !_hasError)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.video.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.video.creator,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: purpleAccent.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${_formatViews(widget.video.views)} views',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('PARTICIPATE'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onTap();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _showDeleteConfirmation(context, purpleAccent);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.15),
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return widget.video.thumbnailUrl.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: widget.video.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ShimmerLoadingPlaceholder(
              width: double.infinity,
              height: double.infinity,
              shapeBorder: BeveledRectangleBorder(),
            ),
            errorWidget: (context, url, error) {
              ErrorLoggingService.instance
                  .logError(error, context: 'VideoCard.thumbnail');
              return const PlaceholderThumbnail(
                width: double.infinity,
                height: double.infinity,
              );
            },
          )
        : const PlaceholderThumbnail(
            width: double.infinity,
            height: double.infinity,
          );
  }

  Widget _buildInitialPlayButton(Color accentColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon:
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
        onPressed: _togglePlayPause,
      ),
    );
  }

  Widget _buildErrorState(Color accentColor) {
    return ColoredBox(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isNetworkError
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _isNetworkError ? 'Network Error' : 'Failed to Load Video',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please try again',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('RETRY'),
              onPressed: _retryVideoInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  void _showDeleteConfirmation(BuildContext context, Color accentColor) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Video',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this video? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(dialogContext).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed ?? false) {
        if (mounted && widget.onDelete != null) {
          scaffoldMessenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Text('Deleting video...'),
                  ],
                ),
                backgroundColor: Color(0xFF1A1A1A),
                duration: Duration(seconds: 2),
              ),
            );
          _performDelete(scaffoldMessenger);
        }
      }
    });
  }

  Future<void> _performDelete(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final success = await widget.onDelete!(widget.video.id);
      if (!mounted) return;
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Video deleted successfully' : 'Failed to delete video',
            ),
            backgroundColor: success ? Colors.green : Colors.redAccent,
          ),
        );
    } catch (e) {
      ErrorLoggingService.instance
          .logError(e, context: 'VideoCard._performDelete');
      if (!mounted) return;
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('An error occurred while deleting the video'),
            backgroundColor: Colors.redAccent,
          ),
        );
    }
  }
}
