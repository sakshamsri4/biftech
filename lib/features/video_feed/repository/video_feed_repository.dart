import 'dart:convert';

import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// Repository for managing video feed data
class VideoFeedRepository {
  /// Factory constructor to get the singleton instance
  factory VideoFeedRepository() {
    _instance ??= VideoFeedRepository._();
    return _instance!;
  }

  /// Factory constructor for backward compatibility
  factory VideoFeedRepository.getInstance() {
    return VideoFeedRepository();
  }

  /// Private constructor for singleton pattern
  VideoFeedRepository._();

  /// Singleton instance
  static VideoFeedRepository? _instance;

  /// Box for storing videos
  Box<VideoModel>? _videosBox;

  /// Initialize the repository
  Future<void> initialize() async {
    try {
      // Register the VideoModel adapter if not already registered
      if (!Hive.isAdapterRegistered(VideoModelAdapter().typeId)) {
        Hive.registerAdapter(VideoModelAdapter());
      }

      // Open the videos box
      _videosBox = await Hive.openBox<VideoModel>('videos');

      // Clear any existing videos to start fresh
      await _videosBox!.clear();

      // Load videos from assets to ensure we start with
      // exactly the videos in the JSON file
      await loadVideosFromAssets();

      debugPrint('VideoFeedRepository initialized successfully');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedRepository.initialize',
      );
      rethrow;
    }
  }

  /// Load videos from Hive storage
  Future<List<VideoModel>> loadVideosFromStorage() async {
    try {
      if (_videosBox == null) {
        throw Exception('Videos box is not initialized');
      }

      // Get all videos from the box
      final videos = _videosBox!.values.toList();

      debugPrint('Loaded ${videos.length} videos from Hive storage');

      // If no videos in storage, load from assets
      if (videos.isEmpty) {
        return loadVideosFromAssets();
      }

      return videos;
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedRepository.loadVideosFromStorage',
      );
      // If loading from Hive fails, fall back to loading from assets
      return loadVideosFromAssets();
    }
  }

  /// Load videos from assets
  Future<List<VideoModel>> loadVideosFromAssets() async {
    try {
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString('assets/json/videos.json');

      // Parse the JSON
      final jsonList = json.decode(jsonString) as List<dynamic>;

      // Convert to VideoModel objects
      final videos = jsonList
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Save the videos to Hive storage
      await saveVideosToStorage(videos);

      debugPrint('Loaded ${videos.length} videos from assets');

      return videos;
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedRepository.loadVideosFromAssets',
      );
      // Return empty list if loading fails
      return [];
    }
  }

  /// Save videos to Hive storage
  Future<void> saveVideosToStorage(List<VideoModel> videos) async {
    try {
      if (_videosBox == null) {
        throw Exception('Videos box is not initialized');
      }

      // Clear the box first
      await _videosBox!.clear();

      // Add all videos to the box
      for (final video in videos) {
        await _videosBox!.put(video.id, video);
      }

      debugPrint('Saved ${videos.length} videos to Hive storage');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedRepository.saveVideosToStorage',
      );
    }
  }

  /// Add a new video to storage
  Future<void> addVideo(VideoModel video) async {
    try {
      if (_videosBox == null) {
        throw Exception('Videos box is not initialized');
      }

      // Add the video to the box
      await _videosBox!.put(video.id, video);

      debugPrint('Added video ${video.id} to Hive storage');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedRepository.addVideo',
      );
    }
  }

  /// Delete a video from storage
  Future<bool> deleteVideo(String videoId) async {
    try {
      if (_videosBox == null) {
        throw Exception('Videos box is not initialized');
      }

      // Check if the video exists
      if (!_videosBox!.containsKey(videoId)) {
        debugPrint('Video $videoId not found in storage');
        return false;
      }

      // Delete the video from the box
      await _videosBox!.delete(videoId);

      debugPrint('Deleted video $videoId from Hive storage');
      return true;
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'VideoFeedRepository.deleteVideo',
      );
      return false;
    }
  }

  /// Generates a new video ID
  String generateVideoId() {
    return 'v${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Gets a default thumbnail URL for new videos
  String getDefaultThumbnailUrl() {
    // Use a placeholder image from assets
    return 'assets/images/default_thumbnail.jpg';
  }

  /// Gets a default video URL from assets
  String getDefaultVideoUrl() {
    // Use one of the videos from assets
    final videos = [
      'assets/videos/UTsR5nzN.mp4',
      'assets/videos/3638-172489056_small.mp4',
    ];
    // Return a random video
    return videos[DateTime.now().millisecond % videos.length];
  }
}
