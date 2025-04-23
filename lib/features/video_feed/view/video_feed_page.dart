import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/upload_video_page.dart';
import 'package:biftech/features/video_feed/view/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopop/neopop.dart';

/// {@template video_feed_page}
/// Page that displays a feed of videos.
/// {@endtemplate}
class VideoFeedPage extends StatelessWidget {
  /// {@macro video_feed_page}
  const VideoFeedPage({super.key});

  /// Route name for this page
  static const routeName = '/video-feed';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          VideoFeedCubit(), // Creates or reuses the singleton instance
      // Don't close the cubit when the provider is disposed
      // since it's a singleton and will be reused
      lazy: false,
      child: const VideoFeedView(),
    );
  }
}

/// {@template video_feed_view}
/// Main view for the video feed page with enhanced video playback.
/// {@endtemplate}
class VideoFeedView extends StatefulWidget {
  /// {@macro video_feed_view}
  const VideoFeedView({super.key});

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView>
    with WidgetsBindingObserver {
  late VideoFeedCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = context.read<VideoFeedCubit>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause videos when app goes to background
    if (state == AppLifecycleState.paused) {
      _cubit.pauseAllVideos();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Pause all videos when the view is disposed
    // Note: We don't dispose controllers here since the cubit is a singleton
    // and will be reused when navigating back to this page
    _cubit.pauseAllVideos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'VIDEO FEED',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: Builder(
        builder: (innerContext) => NeoPopButton(
          color: const Color(0xFF6C63FF),
          onTapUp: () {
            HapticFeedback.mediumImpact();
            // Get the cubit from the correct context
            final cubit = BlocProvider.of<VideoFeedCubit>(innerContext);

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: const UploadVideoPage(),
                ),
              ),
            );
          },
          onTapDown: HapticFeedback.lightImpact,
          parentColor: const Color(0xFF0A0A0A),
          depth: 10,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'UPLOAD VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<VideoFeedCubit, VideoFeedState>(
        builder: (context, state) {
          switch (state.status) {
            case VideoFeedStatus.initial:
            case VideoFeedStatus.loading:
              if (state.videos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6C63FF),
                    ),
                  ),
                );
              }
              // If we have videos but are refreshing,
              // show the list with a loading indicator
              return _VideoList(
                videos: state.videos,
                isRefreshing: true,
              );

            case VideoFeedStatus.success:
              if (state.videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.videocam_off_rounded,
                          size: 60,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Videos Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload your first video to get started',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _VideoList(videos: state.videos);

            case VideoFeedStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeoPopButton(
                      color: const Color(0xFF6C63FF),
                      onTapUp: () {
                        HapticFeedback.mediumImpact();
                        context.read<VideoFeedCubit>().loadVideos();
                      },
                      onTapDown: HapticFeedback.lightImpact,
                      parentColor: const Color(0xFF0A0A0A),
                      depth: 8,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Text(
                          'TRY AGAIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

/// {@template video_list}
/// Widget that displays a list of videos with pull-to-refresh functionality.
/// {@endtemplate}
class _VideoList extends StatefulWidget {
  /// {@macro video_list}
  const _VideoList({
    required this.videos,
    this.isRefreshing = false,
  });

  /// List of videos to display
  final List<dynamic> videos;

  /// Whether the list is currently refreshing
  final bool isRefreshing;

  @override
  State<_VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<_VideoList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<VideoFeedCubit>().refreshVideos();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: widget.videos.length,
            itemBuilder: (context, index) {
              final video = widget.videos[index] as VideoModel;

              // Create a staggered animation for each item
              final itemAnimation = Tween<double>(
                begin: 0,
                end: 1,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    index * 0.05, // Stagger based on index
                    1,
                    curve: Curves.easeOut,
                  ),
                ),
              );
              return FadeTransition(
                opacity: itemAnimation,
                child: VideoCard(
                  video: video,
                  onTap: () {
                    // Pause all videos before navigating
                    context.read<VideoFeedCubit>().pauseAllVideos();

                    // Add haptic feedback
                    HapticFeedback.mediumImpact();

                    // Navigate to flowchart page with video ID
                    Navigator.pushNamed(
                      context,
                      '/flowchart/${video.id}',
                    );
                  },
                  onDelete: (videoId) async {
                    // Call the delete method in the cubit
                    return context.read<VideoFeedCubit>().deleteVideo(videoId);
                  },
                ),
              );
            },
          ),
        ),
        if (widget.isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFFFF6584),
                    Color(0xFF6C63FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
