import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/upload_video_page.dart';
import 'package:biftech/features/video_feed/view/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: AppBar(
        title: const Text('Video Feed'),
      ),
      floatingActionButton: Builder(
        builder: (innerContext) => FloatingActionButton.extended(
          onPressed: () {
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
          icon: const Icon(Icons.add),
          label: const Text('Upload Video'),
        ),
      ),
      body: BlocBuilder<VideoFeedCubit, VideoFeedState>(
        builder: (context, state) {
          switch (state.status) {
            case VideoFeedStatus.initial:
            case VideoFeedStatus.loading:
              if (state.videos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
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
                return const Center(
                  child: Text('No videos available'),
                );
              }
              return _VideoList(videos: state.videos);

            case VideoFeedStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VideoFeedCubit>().loadVideos();
                      },
                      child: const Text('Try Again'),
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
class _VideoList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<VideoFeedCubit>().refreshVideos();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index] as VideoModel;
              return VideoCard(
                video: video,
                onTap: () {
                  // Pause all videos before navigating
                  context.read<VideoFeedCubit>().pauseAllVideos();

                  // Navigate to flowchart page with video ID
                  Navigator.pushNamed(
                    context,
                    '/flowchart/:id',
                    arguments: {'id': video.id},
                  );
                },
                onDelete: (videoId) async {
                  // Call the delete method in the cubit
                  return context.read<VideoFeedCubit>().deleteVideo(videoId);
                },
              );
            },
          ),
        ),
        if (isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
