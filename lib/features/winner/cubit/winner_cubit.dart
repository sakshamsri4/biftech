import 'dart:async';

import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/cubit/flowchart_cubit.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/features/winner/cubit/winner_state.dart';
import 'package:biftech/features/winner/model/winner_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing winner declaration
class WinnerCubit extends Cubit<WinnerState> {
  /// Constructor
  WinnerCubit({
    required this.flowchartCubit,
  }) : super(WinnerState.initial);

  /// Flowchart cubit for accessing the flowchart data
  final FlowchartCubit flowchartCubit;

  /// Timer for simulating the evaluation period
  Timer? _evaluationTimer;

  @override
  Future<void> close() {
    _evaluationTimer?.cancel();
    return super.close();
  }

  /// Declare a winner for the flowchart
  Future<void> declareWinner() async {
    try {
      emit(state.copyWith(status: WinnerStatus.loading));

      // Find the winning node
      final winningNode = flowchartCubit.findWinningNode();
      if (winningNode == null) {
        emit(
          state.copyWith(
            status: WinnerStatus.failure,
            error: 'No winner found',
          ),
        );
        return;
      }

      // Calculate total donations
      final totalDonations = flowchartCubit.calculateTotalDonations();

      // Calculate distribution
      final winnerShare = totalDonations * 0.6;
      final appShare = totalDonations * 0.2;
      final platformShare = totalDonations * 0.2;

      // Create winner model
      final winner = WinnerModel(
        winningNode: winningNode,
        totalDonations: totalDonations,
        winnerShare: winnerShare,
        appShare: appShare,
        platformShare: platformShare,
      );

      // Start the evaluation timer (24-hour evaluation)
      // For demo purposes, we provide a way to speed up the timer
      // In a real app, this would be a fixed 24-hour duration
      final evaluationDuration = _getEvaluationDuration();
      final remainingTime = evaluationDuration;

      emit(
        state.copyWith(
          status: WinnerStatus.waiting,
          winner: winner,
          remainingTime: remainingTime,
        ),
      );

      // Start the timer to simulate the evaluation period
      _startEvaluationTimer(evaluationDuration);
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'WinnerCubit.declareWinner',
      );
      emit(
        state.copyWith(
          status: WinnerStatus.failure,
          error: 'Failed to declare winner: $e',
        ),
      );
    }
  }

  /// Start the evaluation timer
  void _startEvaluationTimer(Duration duration) {
    // Cancel any existing timer
    _evaluationTimer?.cancel();

    // Create a new timer that updates the remaining time every second
    var remainingTime = duration;
    _evaluationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime = remainingTime - const Duration(seconds: 1);

      if (remainingTime.inSeconds <= 0) {
        // Evaluation complete
        timer.cancel();
        emit(
          state.copyWith(
            status: WinnerStatus.success,
            remainingTime: Duration.zero,
          ),
        );
      } else {
        // Update remaining time
        emit(
          state.copyWith(
            remainingTime: remainingTime,
          ),
        );
      }
    });
  }

  /// Cancel the evaluation timer
  void cancelEvaluation() {
    _evaluationTimer?.cancel();
    emit(WinnerState.initial);
  }

  /// Find the node with the highest score in the flowchart
  NodeModel? findWinningNode() {
    return flowchartCubit.findWinningNode();
  }

  /// Calculate the total donations in the flowchart
  double calculateTotalDonations() {
    return flowchartCubit.calculateTotalDonations();
  }

  /// Get the evaluation duration based on environment
  Duration _getEvaluationDuration() {
    // Check if we're in debug mode or testing environment
    assert(
      () {
        // In debug mode, use a shorter duration for testing
        return true;
      }(),
      'This assert is only used to check if we are in debug mode',
    );

    // For demo/debug purposes, use a shorter duration (10 seconds)
    // In production, this would be 24 hours
    const debugDuration = Duration(seconds: 10);

    // In a real production app, we would use:
    // return const Duration(hours: 24);

    // For this demo, always use the debug duration
    return debugDuration;
  }

  /// Speed up the timer (for testing purposes only)
  void speedUpTimer() {
    if (_evaluationTimer != null && state.status == WinnerStatus.waiting) {
      // Cancel the current timer
      _evaluationTimer!.cancel();

      // Set a very short remaining time
      const remainingTime = Duration(seconds: 3);

      // Update the state
      emit(
        state.copyWith(
          remainingTime: remainingTime,
        ),
      );

      // Start a new timer with the shorter duration
      _startEvaluationTimer(remainingTime);
    }
  }
}
