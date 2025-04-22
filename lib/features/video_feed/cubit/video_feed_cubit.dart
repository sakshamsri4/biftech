import 'dart:async';
import 'dart:io';

import 'package:biftech/core/constants/error_messages.dart';
import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/video_feed/cubit/video_feed_state.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/repository/repository.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

/// {@template video_feed_cubit}
/// Cubit that manages the state of the video feed.
/// {@endtemplate}
class VideoFeedCubit extends Cubit<VideoFeedState> {
  /// Factory constructor to get the singleton instance
  factory VideoFeedCubit() {
    if (_instance != null && !_instance!.isClosed) {
      return _instance!;
    }
    _instance = VideoFeedCubit._internal(VideoFeedRepository.instance);
    return _instance!;
  }

  /// Internal constructor with repository dependency
  VideoFeedCubit._internal(this._repository) : super(VideoFeedState.initial) {
    // Load videos when the cubit is created
    loadVideos();
  }

  /// Singleton instance
  static VideoFeedCubit? _instance;

  /// Repository for video feed data
  final VideoFeedRepository _repository;

  /// Map of video controllers by video ID
  final Map<String, VideoPlayerController> _controllers = {};

  /// Get the controller for a video
  VideoPlayerController? getControllerForVideo(String videoId) {
    return _controllers[videoId];
  }

  /// Initialize a video controller for a video
  Future<void> initializeVideoController(VideoModel video) async {
    // Skip if the video URL is empty or controller already exists
    if (video.videoUrl.isEmpty ||
        _controllers.containsKey(video.id) ||
        isClosed) {
      return;
    }

    try {
      // Create a new controller based on the video URL type
      final VideoPlayerController controller;

      // Check if the file exists for local files
      if (!video.videoUrl.startsWith('http') &&
          !video.videoUrl.startsWith('assets/') &&
          !kIsWeb) {
        final file = File(video.videoUrl);
        try {
          final exists = file.existsSync();
          if (!exists) {
            debugPrint('Video file does not exist: ${video.videoUrl}');
            if (!isClosed) {
              emit(state.copyWith(errorMessage: 'Video file not found'));
            }
            return;
          }
        } catch (e) {
          debugPrint('Error checking if file exists: $e');
          if (!isClosed) {
            emit(state.copyWith(errorMessage: 'Error accessing video file'));
          }
          return;
        }
      }

      if (video.videoUrl.startsWith('http')) {
        // Network video
        controller = VideoPlayerController.networkUrl(
          Uri.parse(video.videoUrl),
        );
      } else if (video.videoUrl.startsWith('assets/')) {
        // Asset video
        controller = VideoPlayerController.asset(video.videoUrl);
      } else if (kIsWeb) {
        // On web, we can only use network URLs
        controller = VideoPlayerController.networkUrl(
          Uri.parse(video.videoUrl),
        );
      } else {
        // File video (from device storage)
        controller = VideoPlayerController.file(
          File(video.videoUrl),
        );
      }

      // Initialize the controller with timeout
      var initialized = false;
      try {
        await controller.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Video initialization timed out');
          },
        );
        initialized = true;
      } catch (e) {
        // Handle initialization error
        ErrorLoggingService.instance.logError(
          e,
          context: 'VideoFeedCubit.initializeVideoController.initialize',
        );
        // Dispose the controller if initialization failed
        await controller.dispose();
        rethrow; // Re-throw to be caught by the outer try-catch
      }

      if (initialized) {
        // Add to the controllers map
        _controllers[video.id] = controller;

        // Check if the cubit is closed before emitting
        if (!isClosed) {
          // Emit a state update to trigger a rebuild
          emit(state.copyWith());
        }
      }
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.initializeVideoController',
      );

      // Check if the cubit is closed before emitting
      if (!isClosed) {
        // Emit a user-friendly error message
        emit(
          state.copyWith(
            errorMessage: ErrorMessages.videoPlayback,
          ),
        );
      }
    }
  }

  /// Play a video and pause all others
  Future<void> playVideo(String videoId) async {
    if (isClosed) return;

    try {
      // Get the current videos
      final currentVideos = List<VideoModel>.from(state.videos);

      // Update the playing state for all videos
      final updatedVideos = currentVideos.map((video) {
        final isCurrentVideo = video.id == videoId;
        return video.copyWith(isPlaying: isCurrentVideo);
      }).toList();

      // Pause all controllers except the one being played
      for (final entry in _controllers.entries) {
        try {
          if (entry.key == videoId) {
            await entry.value.play();
          } else {
            await entry.value.pause();
          }
        } catch (e) {
          // Log error but continue with other controllers
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoFeedCubit.playVideo.controller',
          );
        }
      }

      // Check again if the cubit is closed before emitting
      if (!isClosed) {
        // Update the state
        emit(state.copyWith(videos: updatedVideos));
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.playVideo',
      );

      // Check if the cubit is closed before emitting error state
      if (!isClosed) {
        emit(state.copyWith(errorMessage: ErrorMessages.videoPlayback));
      }
    }
  }

  /// Pause a specific video
  Future<void> pauseVideo(String videoId) async {
    if (isClosed) return;

    try {
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

      // Check if the cubit is closed before emitting
      if (!isClosed) {
        // Update the state
        emit(state.copyWith(videos: updatedVideos));
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.pauseVideo',
      );
    }
  }

  /// Pause all videos
  Future<void> pauseAllVideos() async {
    if (isClosed) return;

    try {
      // Pause all controllers with error handling
      for (final controller in _controllers.values) {
        try {
          await controller.pause();
        } catch (e) {
          // Log error but continue with other controllers
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoFeedCubit.pauseAllVideos.controller',
          );
        }
      }

      // Get the current videos
      final currentVideos = List<VideoModel>.from(state.videos);

      // Update the playing state for all videos
      final updatedVideos = currentVideos.map((video) {
        return video.copyWith(isPlaying: false);
      }).toList();

      // Check if the cubit is closed before emitting
      if (!isClosed) {
        // Update the state
        emit(state.copyWith(videos: updatedVideos));
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.pauseAllVideos',
      );
    }
  }

  /// Dispose all video controllers
  Future<void> disposeControllers() async {
    try {
      // Create a copy of the controllers to avoid concurrent modification
      final controllersCopy =
          Map<String, VideoPlayerController>.from(_controllers);

      // Pause all controllers first to ensure they're in a safe state
      for (final controller in controllersCopy.values) {
        try {
          if (controller.value.isInitialized) {
            await controller.pause();
          }
        } catch (e) {
          // Log error but continue with other controllers
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoFeedCubit.disposeControllers.pause',
          );
        }
      }

      // Dispose all controllers with error handling
      for (final entry in controllersCopy.entries) {
        try {
          await entry.value.dispose();
          // Remove from the original map after successful disposal
          _controllers.remove(entry.key);
        } catch (e) {
          // Log error but continue with other controllers
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoFeedCubit.disposeControllers.dispose',
          );
        }
      }
    } catch (e) {
      ErrorLoggingService.instance.logError(
        e,
        context: 'VideoFeedCubit.disposeControllers',
      );
    }
  }

  @override
  Future<void> close() async {
    // Dispose all controllers when the cubit is closed
    await disposeControllers();
    return super.close();
  }

  /// Loads videos from the repository
  Future<void> loadVideos() async {
    emit(state.copyWith(status: VideoFeedStatus.loading));

    try {
      // Load videos from the repository
      final videos = await _repository.loadVideosFromStorage();

      // Emit success state with videos
      emit(
        state.copyWith(
          status: VideoFeedStatus.success,
          videos: videos,
        ),
      );

      debugPrint('Loaded ${videos.length} videos from repository');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.loadVideos',
      );

      // Emit failure state with user-friendly error message
      emit(
        state.copyWith(
          status: VideoFeedStatus.failure,
          errorMessage: ErrorMessages.videoLoading,
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
      // Load videos from assets (this will also save to storage)
      final videos = await _repository.loadVideosFromAssets();

      // Emit success state with videos
      emit(
        state.copyWith(
          status: VideoFeedStatus.success,
          videos: videos,
        ),
      );

      debugPrint('Refreshed ${videos.length} videos from assets');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.refreshVideos',
      );

      // Emit failure state with user-friendly error message
      emit(
        state.copyWith(
          status: VideoFeedStatus.failure,
          errorMessage: ErrorMessages.videoLoading,
        ),
      );
    }
  }

  /// Adds a new video to the feed
  Future<void> addNewVideo(VideoModel newVideo) async {
    try {
      // Get the current videos
      final currentVideos = List<VideoModel>.from(state.videos)

        // Add the new video at the beginning of the list
        ..insert(0, newVideo);

      // Emit success state with updated videos
      emit(
        state.copyWith(
          status: VideoFeedStatus.success,
          videos: currentVideos,
        ),
      );

      // Initialize the video controller for the new video
      await initializeVideoController(newVideo);

      // Save the updated videos to storage
      await _repository.saveVideosToStorage(currentVideos);

      debugPrint('Added new video: ${newVideo.id}');
      debugPrint('Saved ${currentVideos.length} videos to storage');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.addNewVideo',
      );

      // Emit failure state with user-friendly error message
      emit(
        state.copyWith(
          status: VideoFeedStatus.failure,
          errorMessage: ErrorMessages.videoUpload,
        ),
      );
    }
  }

  /// Deletes a video from the feed
  Future<bool> deleteVideo(String videoId) async {
    if (isClosed) return false;

    try {
      // Pause and dispose the controller if it exists
      final controller = _controllers[videoId];
      if (controller != null) {
        try {
          await controller.pause();
          await controller.dispose();
          _controllers.remove(videoId);
        } catch (e) {
          // Log error but continue with deletion
          ErrorLoggingService.instance.logError(
            e,
            context: 'VideoFeedCubit.deleteVideo.controller',
          );
        }
      }

      // Get the current videos
      final currentVideos = List<VideoModel>.from(state.videos);

      // Find the video to delete
      final videoIndex =
          currentVideos.indexWhere((video) => video.id == videoId);

      if (videoIndex == -1) {
        debugPrint('Video $videoId not found in state');
        return false;
      }

      // Remove the video from the list
      currentVideos.removeAt(videoIndex);

      // Delete from storage
      final deleted = await _repository.deleteVideo(videoId);

      if (!deleted) {
        debugPrint('Failed to delete video $videoId from storage');
        return false;
      }

      // Save the updated list to storage
      await _repository.saveVideosToStorage(currentVideos);

      // Check if the cubit is closed before emitting
      if (!isClosed) {
        // Update the state
        emit(
          state.copyWith(
            videos: currentVideos,
            status: VideoFeedStatus.success,
          ),
        );
      }

      debugPrint('Deleted video: $videoId');
      return true;
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedCubit.deleteVideo',
      );

      // Emit failure state with user-friendly error message
      if (!isClosed) {
        emit(
          state.copyWith(
            status: VideoFeedStatus.failure,
            errorMessage: 'Failed to delete video. Please try again.',
          ),
        );
      }

      return false;
    }
  }
}
