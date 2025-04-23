import 'package:biftech/features/video_feed/model/models.dart';
import 'package:equatable/equatable.dart';

/// {@template video_feed_state}
/// Represents the state of the video feed.
/// {@endtemplate}
class VideoFeedState extends Equatable {
  /// {@macro video_feed_state}
  const VideoFeedState({
    this.status = VideoFeedStatus.initial,
    this.videos = const [],
    this.errorMessage = '',
  });

  /// The current status of the video feed
  final VideoFeedStatus status;

  /// List of videos in the feed
  final List<VideoModel> videos;

  /// Error message if status is [VideoFeedStatus.failure]
  final String errorMessage;

  /// Initial state of the video feed
  static const initial = VideoFeedState();

  @override
  List<Object> get props => [status, videos, errorMessage];

  /// Creates a copy of this [VideoFeedState] with the given fields replaced.
  VideoFeedState copyWith({
    VideoFeedStatus? status,
    List<VideoModel>? videos,
    String? errorMessage,
  }) {
    return VideoFeedState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Status of the video feed
enum VideoFeedStatus {
  /// Initial state
  initial,

  /// Loading videos
  loading,

  /// Successfully loaded videos
  success,

  /// Failed to load videos
  failure,
}
