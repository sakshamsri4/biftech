import 'dart:convert';

import 'package:biftech/features/video_feed/cubit/video_feed_state.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template video_feed_cubit}
/// Cubit that manages the state of the video feed.
/// {@endtemplate}
class VideoFeedCubit extends Cubit<VideoFeedState> {
  /// {@macro video_feed_cubit}
  VideoFeedCubit() : super(VideoFeedState.initial);

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
