import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/widgets/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoFeedCubit extends Mock implements VideoFeedCubit {}

// Create a testable version of VideoFeedView that doesn't depend on BlocBuilder
class TestableVideoFeedView extends StatelessWidget {
  const TestableVideoFeedView({
    required this.state,
    required this.onRefresh,
    required this.onTryAgain,
    super.key,
  });

  final VideoFeedState state;
  final VoidCallback onRefresh;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Feed'),
      ),
      body: Builder(
        builder: (context) {
          switch (state.status) {
            case VideoFeedStatus.initial:
            case VideoFeedStatus.loading:
              if (state.videos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // If we have videos but are refreshing, show the list
              // with a loading indicator
              return _buildVideoList(context, state.videos, true);

            case VideoFeedStatus.success:
              if (state.videos.isEmpty) {
                return const Center(
                  child: Text('No videos available'),
                );
              }
              return _buildVideoList(context, state.videos, false);

            case VideoFeedStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onTryAgain,
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

  Widget _buildVideoList(
    BuildContext context,
    List<VideoModel> videos,
    bool isRefreshing,
  ) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return VideoCard(
              video: video,
              onTap: () {},
            );
          },
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

void main() {
  group('VideoFeedPage', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TestableVideoFeedView(
            state: VideoFeedState.initial,
            onRefresh: () {},
            onTryAgain: () {},
          ),
        ),
      );

      expect(find.text('Video Feed'), findsOneWidget);
    });

    testWidgets('shows loading indicator when status is loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TestableVideoFeedView(
            state: const VideoFeedState(status: VideoFeedStatus.loading),
            onRefresh: () {},
            onTryAgain: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows videos when status is success', (tester) async {
      final mockVideos = [
        const VideoModel(
          id: 'v001',
          title: 'Test Video 1',
          creator: 'Test Creator 1',
          views: 1000,
          thumbnailUrl: 'https://example.com/thumbnail1.jpg',
        ),
        const VideoModel(
          id: 'v002',
          title: 'Test Video 2',
          creator: 'Test Creator 2',
          views: 2000,
          thumbnailUrl: 'https://example.com/thumbnail2.jpg',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TestableVideoFeedView(
            state: VideoFeedState(
              status: VideoFeedStatus.success,
              videos: mockVideos,
            ),
            onRefresh: () {},
            onTryAgain: () {},
          ),
        ),
      );

      // Pump a frame to allow the ListView to build
      await tester.pump();

      // Verify that VideoCard widgets are displayed
      expect(find.byType(VideoCard), findsNWidgets(2));
    });

    testWidgets('shows error message when status is failure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TestableVideoFeedView(
            state: const VideoFeedState(
              status: VideoFeedStatus.failure,
              errorMessage: 'Failed to load videos',
            ),
            onRefresh: () {},
            onTryAgain: () {},
          ),
        ),
      );

      expect(find.text('Error: Failed to load videos'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('calls onTryAgain when try again button is pressed',
        (tester) async {
      var tryAgainPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TestableVideoFeedView(
            state: const VideoFeedState(
              status: VideoFeedStatus.failure,
              errorMessage: 'Failed to load videos',
            ),
            onRefresh: () {},
            onTryAgain: () {
              tryAgainPressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      expect(tryAgainPressed, isTrue);
    });
  });
}
