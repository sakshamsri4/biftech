import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/widgets/placeholder_thumbnail.dart';
import 'package:biftech/features/video_feed/view/widgets/shimmer_loading.dart';
import 'package:biftech/shared/theme/dimens.dart';
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
              'Successfully initialized controller for video: ${widget.video.id}',
            );
          } else {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          }
        } catch (e) {
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoCard._initializeController.initialize',
          );
          debugPrint(
            'Failed to initialize controller for video: ${widget.video.id}: $e',
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
            Future.delayed(const Duration(seconds: 3), () {
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
          'Successfully reinitialized controller for video: ${widget.video.id}',
        );
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isNetworkError = false;
        });
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content:
                const Text('Failed to load video. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
        SnackBar(
          content: const Text('Failed to load video. Please try again later.'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
            Future.delayed(const Duration(seconds: 3), () {
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
            SnackBar(
              content: const Text('Failed to play video. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
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
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to play video. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
            Future.delayed(const Duration(seconds: 3), () {
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceM,
        vertical: AppDimens.spaceS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(AppDimens.radiusXL),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withAlpha((0.3 * 255).round()), // Use withAlpha
              blurRadius: 10,
              offset: const Offset(0, AppDimens.spaceXXS),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radiusXL),
                topRight: Radius.circular(AppDimens.radiusXL),
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
                        child: RepaintBoundary(
                          child: FadeTransition(
                            opacity: _controlsOpacity,
                            child: ColoredBox(
                              color: Colors.black.withAlpha(
                                  (0.4 * 255).round()), // Use withAlpha
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
                                    backgroundColor: purpleAccent.withAlpha(
                                        (0.8 * 255).round()), // Use withAlpha
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  onPressed: _togglePlayPause,
                                ),
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
                        bottom: AppDimens.spaceXS,
                        right: AppDimens.spaceXS,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.spaceXS,
                            vertical: AppDimens.spaceXXS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(
                                (0.7 * 255).round()), // Use withAlpha
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusS),
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
              padding: const EdgeInsets.all(AppDimens.spaceM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.spaceXS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.video.creator,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: purpleAccent.withAlpha(
                                  (0.8 * 255).round()), // Use withAlpha
                            ),
                      ),
                      Text(
                        '${_formatViews(widget.video.views)} views',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.spaceM),
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
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                backgroundColor:
                                    WidgetStateProperty.all(purpleAccent),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.white),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                    vertical: AppDimens.spaceS,
                                  ),
                                ),
                                textStyle: WidgetStateProperty.resolveWith(
                                  (states) => Theme.of(context)
                                      .elevatedButtonTheme
                                      .style
                                      ?.textStyle
                                      ?.resolve(states)
                                      ?.copyWith(letterSpacing: 0.8),
                                ),
                              ),
                        ),
                      ),
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: AppDimens.spaceS),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _showDeleteConfirmation(context, purpleAccent);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .error
                                .withAlpha(
                                    (0.15 * 255).round()), // Use withAlpha
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                            padding: const EdgeInsets.all(AppDimens.spaceS),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusM),
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
        color: accentColor.withAlpha((0.9 * 255).round()), // Use withAlpha
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()), // Use withAlpha
            blurRadius: AppDimens.spaceXS,
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
              color: Theme.of(context).colorScheme.error,
              size: AppDimens.spaceXXXXL,
            ),
            const SizedBox(height: AppDimens.spaceS),
            Text(
              _isNetworkError ? 'Network Error' : 'Failed to Load Video',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimens.spaceXXS),
            Text(
              'Please try again',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spaceM),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('RETRY'),
              onPressed: _retryVideoInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spaceM,
                  vertical: AppDimens.spaceXS,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
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
        title: Text(
          'Delete Video',
          style: Theme.of(context).dialogTheme.titleTextStyle,
        ),
        content: Text(
          'Are you sure you want to delete this video? This action cannot be undone.',
          style: Theme.of(context).dialogTheme.contentTextStyle,
        ),
        actionsPadding: const EdgeInsets.all(AppDimens.spaceM),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: Theme.of(context).textButtonTheme.style?.copyWith(
                  foregroundColor: WidgetStateProperty.all(accentColor),
                ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(dialogContext).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: AppDimens.spaceM),
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
            backgroundColor:
                success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
    } catch (e) {
      ErrorLoggingService.instance
          .logError(e, context: 'VideoCard._performDelete');
      if (!mounted) return;
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('An error occurred while deleting the video'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }
}
