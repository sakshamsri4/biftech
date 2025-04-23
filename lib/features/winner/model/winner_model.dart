import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:equatable/equatable.dart';

/// Model representing the winner of a flowchart discussion
class WinnerModel extends Equatable {
  /// Constructor
  const WinnerModel({
    required this.winningNode,
    required this.totalDonations,
    required this.winnerShare,
    required this.appShare,
    required this.platformShare,
    this.evaluationTime = const Duration(hours: 24),
  });

  /// The winning node
  final NodeModel winningNode;

  /// Total donations in the flowchart
  final double totalDonations;

  /// Winner's share of the donations (60%)
  final double winnerShare;

  /// App's share of the donations (20%)
  final double appShare;

  /// Platform's share of the donations (20%)
  final double platformShare;

  /// Time until evaluation (default: 24 hours)
  final Duration evaluationTime;

  /// Create a copy of this model with the given fields replaced
  WinnerModel copyWith({
    NodeModel? winningNode,
    double? totalDonations,
    double? winnerShare,
    double? appShare,
    double? platformShare,
    Duration? evaluationTime,
  }) {
    return WinnerModel(
      winningNode: winningNode ?? this.winningNode,
      totalDonations: totalDonations ?? this.totalDonations,
      winnerShare: winnerShare ?? this.winnerShare,
      appShare: appShare ?? this.appShare,
      platformShare: platformShare ?? this.platformShare,
      evaluationTime: evaluationTime ?? this.evaluationTime,
    );
  }

  @override
  List<Object?> get props => [
        winningNode,
        totalDonations,
        winnerShare,
        appShare,
        platformShare,
        evaluationTime,
      ];
}
