import 'package:equatable/equatable.dart';

/// Model representing a donation
class DonationModel extends Equatable {
  /// Constructor
  const DonationModel({
    required this.id,
    required this.nodeId,
    required this.amount,
    required this.timestamp,
  });

  /// Create donation from JSON
  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String,
      nodeId: json['nodeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Unique identifier for the donation
  final String id;

  /// ID of the node being donated to
  final String nodeId;

  /// Amount of the donation
  final double amount;

  /// Timestamp of the donation
  final DateTime timestamp;

  /// Create a copy of this donation with the given fields replaced
  DonationModel copyWith({
    String? id,
    String? nodeId,
    double? amount,
    DateTime? timestamp,
  }) {
    return DonationModel(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert donation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nodeId': nodeId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, nodeId, amount, timestamp];
}
