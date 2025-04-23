import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/repository/video_feed_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

class MockVideoFeedRepository extends Mock implements VideoFeedRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VideoFeedCubit videoFeedCubit;
  late MockVideoFeedRepository mockRepository;

  // Create mock videos
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

  setUp(() {
    // Create mock repository
    mockRepository = MockVideoFeedRepository();

    // Set up mock repository behavior
    when(() => mockRepository.loadVideosFromStorage())
        .thenAnswer((_) async => mockVideos);
    when(() => mockRepository.loadVideosFromAssets())
        .thenAnswer((_) async => mockVideos);
    when(() => mockRepository.saveVideosToStorage(any()))
        .thenAnswer((_) async {});
    when(() => mockRepository.getDefaultVideoUrl())
        .thenReturn('assets/videos/test.mp4');

    // Create a cubit with the initial state
    videoFeedCubit = VideoFeedCubit()..emit(VideoFeedState.initial);
  });

  tearDown(() {
    videoFeedCubit.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('VideoFeedCubit', () {
    test('initial state is correct', () {
      expect(videoFeedCubit.state, equals(VideoFeedState.initial));
    });

    blocTest<VideoFeedCubit, VideoFeedState>(
      'loadVideos emits [loading, success] when assets load successfully',
      build: () => videoFeedCubit,
      act: (cubit) => cubit.loadVideos(),
      expect: () => [
        const VideoFeedState(status: VideoFeedStatus.loading),
        isA<VideoFeedState>()
            .having((state) => state.status, 'status', VideoFeedStatus.success)
            .having((state) => state.videos.length, 'videos.length', 2),
      ],
    );

    blocTest<VideoFeedCubit, VideoFeedState>(
      'refreshVideos keeps current videos while loading',
      build: () => videoFeedCubit,
      seed: () => const VideoFeedState(
        status: VideoFeedStatus.success,
        videos: [
          VideoModel(
            id: 'old-video',
            title: 'Old Video',
            creator: 'Old Creator',
            views: 500,
            thumbnailUrl: 'https://example.com/old.jpg',
          ),
        ],
      ),
      act: (cubit) => cubit.refreshVideos(),
      expect: () => [
        isA<VideoFeedState>()
            .having((state) => state.status, 'status', VideoFeedStatus.loading)
            .having((state) => state.videos.length, 'videos.length', 1)
            .having(
              (state) => state.videos.first.id,
              'first video id',
              'old-video',
            ),
        isA<VideoFeedState>()
            .having((state) => state.status, 'status', VideoFeedStatus.success)
            .having((state) => state.videos.length, 'videos.length', 2)
            .having((state) => state.videos.first.id, 'first video id', 'v001'),
      ],
    );
  });
}
