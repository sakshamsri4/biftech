import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/view/video_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoFeedCubit extends Mock implements VideoFeedCubit {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockVideoFeedCubit mockVideoFeedCubit;

  setUp(() {
    mockVideoFeedCubit = MockVideoFeedCubit();
  });

  group('VideoFeedPage', () {
    testWidgets('renders VideoFeedView', (tester) async {
      when(() => mockVideoFeedCubit.state).thenReturn(VideoFeedState.initial);
      when(() => mockVideoFeedCubit.loadVideos()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockVideoFeedCubit,
            child: const VideoFeedView(),
          ),
        ),
      );

      expect(find.byType(VideoFeedView), findsOneWidget);
      expect(find.text('Video Feed'), findsOneWidget);
    });

    testWidgets('shows loading indicator when status is loading', (tester) async {
      when(() => mockVideoFeedCubit.state).thenReturn(
        const VideoFeedState(status: VideoFeedStatus.loading),
      );
      when(() => mockVideoFeedCubit.loadVideos()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockVideoFeedCubit,
            child: const VideoFeedView(),
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
        const VideoModel(
          id: 'v003',
          title: 'Test Video 3',
          creator: 'Test Creator 3',
          views: 3000,
          thumbnailUrl: 'https://example.com/thumbnail3.jpg',
        ),
      ];

      when(() => mockVideoFeedCubit.state).thenReturn(
        VideoFeedState(
          status: VideoFeedStatus.success,
          videos: mockVideos,
        ),
      );
      when(() => mockVideoFeedCubit.loadVideos()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockVideoFeedCubit,
            child: const VideoFeedView(),
          ),
        ),
      );

      // Verify that the video titles are displayed
      expect(find.text('Test Video 1'), findsOneWidget);
      expect(find.text('Test Video 2'), findsOneWidget);
      expect(find.text('Test Video 3'), findsOneWidget);

      // Verify that the video creators are displayed
      expect(find.text('Test Creator 1'), findsOneWidget);
      expect(find.text('Test Creator 2'), findsOneWidget);
      expect(find.text('Test Creator 3'), findsOneWidget);
    });

    testWidgets('shows error message when status is failure', (tester) async {
      when(() => mockVideoFeedCubit.state).thenReturn(
        const VideoFeedState(
          status: VideoFeedStatus.failure,
          errorMessage: 'Failed to load videos',
        ),
      );
      when(() => mockVideoFeedCubit.loadVideos()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockVideoFeedCubit,
            child: const VideoFeedView(),
          ),
        ),
      );

      expect(find.text('Error: Failed to load videos'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
