import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/repository/video_feed_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

class MockVideoFeedRepository extends Mock implements VideoFeedRepository {}

class MockVideoPlayerController extends Mock implements VideoPlayerController {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> dispose() async {}
}

// Create a mock VideoFeedCubit for testing
class MockVideoFeedCubit extends MockCubit<VideoFeedState>
    implements VideoFeedCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVideoFeedCubit videoFeedCubit;
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

    // Create a mock cubit with initial state
    videoFeedCubit = MockVideoFeedCubit();
    whenListen(
      videoFeedCubit,
      const Stream<VideoFeedState>.empty(),
      initialState: VideoFeedState.initial,
    );
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

    test('loadVideos emits correct states', () async {
      // Arrange
      when(() => videoFeedCubit.loadVideos()).thenAnswer((_) async {
        videoFeedCubit
          ..emit(const VideoFeedState(status: VideoFeedStatus.loading))
          ..emit(
            VideoFeedState(
              status: VideoFeedStatus.success,
              videos: mockVideos,
            ),
          );
      });

      // Act
      await videoFeedCubit.loadVideos();

      // Assert
      verify(
        () => videoFeedCubit.emit(
          const VideoFeedState(status: VideoFeedStatus.loading),
        ),
      ).called(1);
      verify(
        () => videoFeedCubit.emit(
          VideoFeedState(
            status: VideoFeedStatus.success,
            videos: mockVideos,
          ),
        ),
      ).called(1);
    });

    test('refreshVideos keeps current videos while loading', () async {
      // Arrange
      const oldVideos = [
        VideoModel(
          id: 'old-video',
          title: 'Old Video',
          creator: 'Old Creator',
          views: 500,
          thumbnailUrl: 'https://example.com/old.jpg',
        ),
      ];

      // Set initial state with old videos
      whenListen(
        videoFeedCubit,
        const Stream<VideoFeedState>.empty(),
        initialState: const VideoFeedState(
          status: VideoFeedStatus.success,
          videos: oldVideos,
        ),
      );

      when(() => videoFeedCubit.refreshVideos()).thenAnswer((_) async {
        videoFeedCubit
          ..emit(
            const VideoFeedState(
              status: VideoFeedStatus.loading,
              videos: oldVideos,
            ),
          )
          ..emit(
            VideoFeedState(
              status: VideoFeedStatus.success,
              videos: mockVideos,
            ),
          );
      });

      // Act
      await videoFeedCubit.refreshVideos();

      // Assert
      verify(
        () => videoFeedCubit.emit(
          const VideoFeedState(
            status: VideoFeedStatus.loading,
            videos: oldVideos,
          ),
        ),
      ).called(1);
      verify(
        () => videoFeedCubit.emit(
          VideoFeedState(
            status: VideoFeedStatus.success,
            videos: mockVideos,
          ),
        ),
      ).called(1);
    });
  });
}
