import 'package:equatable/equatable.dart';

/// {@template video_model}
/// Model representing a video in the feed.
/// {@endtemplate}
class VideoModel extends Equatable {
  /// {@macro video_model}
  const VideoModel({
    required this.id,
    required this.title,
    required this.creator,
    required this.views,
    required this.thumbnailUrl,
    this.videoUrl = '',
    this.description = '',
    this.duration = '',
    this.publishedAt = '',
    this.tags = const [],
    this.isPlaying = false,
  });

  /// Creates a [VideoModel] from a JSON object.
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      creator: json['creator'] as String,
      views: json['views'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      videoUrl: json['videoUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );
  }

  /// Unique identifier for the video
  final String id;

  /// Title of the video
  final String title;

  /// Creator/author of the video
  final String creator;

  /// Number of views
  final int views;

  /// URL for the video thumbnail
  final String thumbnailUrl;

  /// URL for the video file
  final String videoUrl;

  /// Description of the video content
  final String description;

  /// Whether the video is currently playing
  final bool isPlaying;

  /// Duration of the video in format "MM:SS"
  final String duration;

  /// ISO 8601 timestamp when the video was published
  final String publishedAt;

  /// List of tags associated with the video
  final List<String> tags;

  /// Converts this [VideoModel] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'views': views,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'description': description,
      'duration': duration,
      'publishedAt': publishedAt,
      'tags': tags,
      // isPlaying is a runtime state and not stored in JSON
    };
  }

  @override
  List<Object> get props => [
        id,
        title,
        creator,
        views,
        thumbnailUrl,
        videoUrl,
        description,
        duration,
        publishedAt,
        tags,
        isPlaying,
      ];

  /// Creates a copy of this [VideoModel] with the given fields replaced.
  VideoModel copyWith({
    String? id,
    String? title,
    String? creator,
    int? views,
    String? thumbnailUrl,
    String? videoUrl,
    String? description,
    String? duration,
    String? publishedAt,
    List<String>? tags,
    bool? isPlaying,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      views: views ?? this.views,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
