import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'node_model.g.dart';

/// Model representing a node in the flowchart
@HiveType(typeId: 3)
class NodeModel extends Equatable {
  /// Constructor
  NodeModel({
    required this.id,
    required this.text,
    this.donation = 0,
    this.comments = const [],
    this.challenges = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create node from JSON
  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      text: json['text'] as String,
      donation: (json['donation'] as num).toDouble(),
      comments: (json['comments'] as List<dynamic>)
          .map((comment) => comment as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map(
            (challenge) => NodeModel.fromJson(
              challenge as Map<String, dynamic>,
            ),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Unique identifier for the node
  @HiveField(0)
  final String id;

  /// Text content of the node
  @HiveField(1)
  final String text;

  /// Donation amount associated with the node
  @HiveField(2)
  final double donation;

  /// List of comments on the node
  @HiveField(3)
  final List<String> comments;

  /// List of challenge nodes
  @HiveField(4)
  final List<NodeModel> challenges;

  /// Creation timestamp
  @HiveField(5)
  final DateTime createdAt;

  /// Create a copy of this node with the given fields replaced
  NodeModel copyWith({
    String? id,
    String? text,
    double? donation,
    List<String>? comments,
    List<NodeModel>? challenges,
    DateTime? createdAt,
  }) {
    return NodeModel(
      id: id ?? this.id,
      text: text ?? this.text,
      donation: donation ?? this.donation,
      comments: comments ?? this.comments,
      challenges: challenges ?? this.challenges,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Add a comment to this node
  NodeModel addComment(String comment) {
    final newComments = List<String>.from(comments)..add(comment);
    return copyWith(comments: newComments);
  }

  /// Add a challenge to this node
  NodeModel addChallenge(NodeModel challenge) {
    final newChallenges = List<NodeModel>.from(challenges)..add(challenge);
    return copyWith(challenges: newChallenges);
  }

  /// Calculate the score of this node (donation + number of comments)
  int get score => donation.toInt() + comments.length;

  /// Convert node to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'donation': donation,
      'comments': comments,
      'challenges': challenges.map((challenge) => challenge.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [id, text, donation, comments, challenges, createdAt];
}
