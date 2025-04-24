import 'package:equatable/equatable.dart';

/// Status of the donation process
enum DonationStatus {
  /// Initial state
  initial,

  /// Loading state
  loading,

  /// Success state
  success,

  /// Failure state
  failure,
}

/// State for the donation cubit
class DonationState extends Equatable {
  /// Constructor
  const DonationState({
    this.status = DonationStatus.initial,
    this.amount = 0.0,
    this.nodeId = '',
    this.errorMessage,
  });

  /// Initial state
  static const initial = DonationState();

  /// Status of the donation process
  final DonationStatus status;

  /// Amount of the donation
  final double amount;

  /// ID of the node being donated to
  final String nodeId;

  /// Error message if donation failed
  final String? errorMessage;

  /// Create a copy of this state with the given fields replaced
  DonationState copyWith({
    DonationStatus? status,
    double? amount,
    String? nodeId,
    String? errorMessage,
  }) {
    return DonationState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      nodeId: nodeId ?? this.nodeId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, amount, nodeId, errorMessage];
}
