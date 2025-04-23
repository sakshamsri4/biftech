import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/repository/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing video feed functionality
class VideoFeedService {
  /// Private constructor to prevent instantiation
  VideoFeedService._();

  /// Singleton instance
  static final VideoFeedService instance = VideoFeedService._();

  /// Whether the service has been initialized
  static bool _isInitialized = false;

  /// Repository instance
  final _repository = VideoFeedRepository();

  /// Initializes the video feed service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      if (!kIsWeb) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }

      // Register adapters
      if (!Hive.isAdapterRegistered(VideoModelAdapter().typeId)) {
        Hive.registerAdapter(VideoModelAdapter());
      }

      // Initialize the repository
      await instance._repository.initialize();

      _isInitialized = true;
      debugPrint('VideoFeedService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize VideoFeedService: $e');
      // Re-throw to allow the caller to handle the error
      rethrow;
    }
  }

  /// Get all videos
  Future<List<VideoModel>> getVideos() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _repository.getVideos();
  }
}
