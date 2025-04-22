import 'dart:convert';

import 'package:biftech/features/video_feed/cubit/video_feed_state.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

/// {@template video_feed_cubit}
/// Cubit that manages the state of the video feed.
/// {@endtemplate}
class VideoFeedCubit extends Cubit<VideoFeedState> {
  /// {@macro video_feed_cubit}
  VideoFeedCubit() : super(VideoFeedState.initial);

  /// Map of video controllers by video ID
  final Map<String, VideoPlayerController> _controllers = {};

  /// Get the controller for a video
  VideoPlayerController? getControllerForVideo(String videoId) {
    return _controllers[videoId];
  }

  /// Initialize a video controller for a video
  Future<void> initializeVideoController(VideoModel video) async {
    // Skip if the video URL is empty or controller already exists
    if (video.videoUrl.isEmpty || _controllers.containsKey(video.id)) {
      return;
    }

    try {
      // Create a new controller
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(video.videoUrl),
      );

      // Initialize the controller
      await controller.initialize();

      // Add to the controllers map
      _controllers[video.id] = controller;
    } catch (e) {
      // Handle initialization error
      emit(
        state.copyWith(
          errorMessage: 'Failed to initialize video player: $e',
        ),
      );
    }
  }

  /// Play a video and pause all others
  Future<void> playVideo(String videoId) async {
    // Get the current videos
    final currentVideos = List<VideoModel>.from(state.videos);

    // Update the playing state for all videos
    final updatedVideos = currentVideos.map((video) {
      final isCurrentVideo = video.id == videoId;
      return video.copyWith(isPlaying: isCurrentVideo);
    }).toList();

    // Pause all controllers except the one being played
    for (final entry in _controllers.entries) {
      if (entry.key == videoId) {
        await entry.value.play();
      } else {
        await entry.value.pause();
      }
    }

    // Update the state
    emit(state.copyWith(videos: updatedVideos));
  }

  /// Pause a specific video
  Future<void> pauseVideo(String videoId) async {
    // Get the controller
    final controller = _controllers[videoId];
    if (controller == null) return;

    // Pause the controller
    await controller.pause();

    // Get the current videos
    final currentVideos = List<VideoModel>.from(state.videos);

    // Update the playing state for the video
    final updatedVideos = currentVideos.map((video) {
      if (video.id == videoId) {
        return video.copyWith(isPlaying: false);
      }
      return video;
    }).toList();

    // Update the state
    emit(state.copyWith(videos: updatedVideos));
  }

  /// Pause all videos
  Future<void> pauseAllVideos() async {
    // Pause all controllers
    for (final controller in _controllers.values) {
      await controller.pause();
    }

    // Get the current videos
    final currentVideos = List<VideoModel>.from(state.videos);

    // Update the playing state for all videos
    final updatedVideos = currentVideos.map((video) {
      return video.copyWith(isPlaying: false);
    }).toList();

    // Update the state
    emit(state.copyWith(videos: updatedVideos));
  }

  /// Dispose all video controllers
  Future<void> disposeControllers() async {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      await controller.dispose();
    }

    // Clear the controllers map
    _controllers.clear();
  }

  @override
  Future<void> close() async {
    // Dispose all controllers when the cubit is closed
    await disposeControllers();
    return super.close();
  }

  /// Loads videos from the mock JSON file
  Future<void> loadVideos() async {
    emit(state.copyWith(status: VideoFeedStatus.loading));

    try {
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString('assets/json/videos.json');

      // Parse the JSON
      final jsonList = json.decode(jsonString) as List<dynamic>;

      // Convert to VideoModel objects
      final videos = jsonList
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Emit success state with videos
      emit(
        state.copyWith(
          status: VideoFeedStatus.success,
          videos: videos,
        ),
      );
    } catch (e) {
      // Emit failure state with error message
      emit(
        state.copyWith(
          status: VideoFeedStatus.failure,
          errorMessage: 'Failed to load videos: $e',
        ),
      );
    }
  }

  /// Refreshes the video feed
  Future<void> refreshVideos() async {
    // Keep the current videos while refreshing
    final currentVideos = state.videos;

    emit(
      state.copyWith(
        status: VideoFeedStatus.loading,
        videos: currentVideos,
      ),
    );

    try {
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString('assets/json/videos.json');

      // Parse the JSON
      final jsonList = json.decode(jsonString) as List<dynamic>;

      // Convert to VideoModel objects
      final videos = jsonList
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Emit success state with videos
      emit(
        state.copyWith(
          status: VideoFeedStatus.success,
          videos: videos,
        ),
      );
    } catch (e) {
      // Emit failure state with error message
      emit(
        state.copyWith(
          status: VideoFeedStatus.failure,
          errorMessage: 'Failed to refresh videos: $e',
        ),
      );
    }
  }
}
