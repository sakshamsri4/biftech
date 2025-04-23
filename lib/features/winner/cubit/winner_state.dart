import 'package:biftech/features/winner/model/winner_model.dart';
import 'package:equatable/equatable.dart';

/// Status of the winner declaration process
enum WinnerStatus {
  /// Initial state
  initial,

  /// Loading winner data
  loading,

  /// Winner declaration successful
  success,

  /// Winner declaration failed
  failure,

  /// Waiting for evaluation period to end
  waiting,
}

/// State for the winner cubit
class WinnerState extends Equatable {
  /// Constructor
  const WinnerState({
    this.status = WinnerStatus.initial,
    this.winner,
    this.error,
    this.remainingTime,
  });

  /// Initial state
  static const initial = WinnerState();

  /// Status of the winner declaration process
  final WinnerStatus status;

  /// Winner data
  final WinnerModel? winner;

  /// Error message
  final String? error;

  /// Remaining time until evaluation
  final Duration? remainingTime;

  /// Create a copy of this state with the given fields replaced
  WinnerState copyWith({
    WinnerStatus? status,
    WinnerModel? winner,
    String? error,
    Duration? remainingTime,
    bool clearError = false,
  }) {
    return WinnerState(
      status: status ?? this.status,
      winner: winner ?? this.winner,
      error: clearError ? null : error ?? this.error,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object?> get props => [status, winner, error, remainingTime];
}
