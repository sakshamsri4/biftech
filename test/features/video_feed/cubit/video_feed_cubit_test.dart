import 'dart:convert';

import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VideoFeedCubit videoFeedCubit;

  // Mock JSON data
  final mockJsonString = jsonEncode([
    {
      'id': 'v001',
      'title': 'Test Video 1',
      'creator': 'Test Creator 1',
      'views': 1000,
      'thumbnailUrl': 'https://example.com/thumbnail1.jpg',
    },
    {
      'id': 'v002',
      'title': 'Test Video 2',
      'creator': 'Test Creator 2',
      'views': 2000,
      'thumbnailUrl': 'https://example.com/thumbnail2.jpg',
    },
  ]);

  setUp(() {
    // Replace the default asset bundle with our mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(mockJsonString)),
      );
    });

    videoFeedCubit = VideoFeedCubit();
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
