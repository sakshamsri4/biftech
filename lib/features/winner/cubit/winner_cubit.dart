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

      // Start the evaluation timer (mock 24-hour evaluation)
      // For demo purposes, we'll use a shorter duration
      const evaluationDuration = Duration(seconds: 10);
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
}
