import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/donation/cubit/donation_state.dart';
import 'package:biftech/features/flowchart/cubit/flowchart_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing donation state
class DonationCubit extends Cubit<DonationState> {
  /// Constructor
  DonationCubit({this.flowchartCubit}) : super(DonationState.initial);

  /// Optional FlowchartCubit to update when donations are processed
  final FlowchartCubit? flowchartCubit;

  /// Process a donation
  Future<void> processDonation({
    required String nodeId,
    required double amount,
    FlowchartCubit? externalFlowchartCubit,
  }) async {
    try {
      // Start loading
      emit(
        state.copyWith(
          status: DonationStatus.loading,
          nodeId: nodeId,
          amount: amount,
        ),
      );

      // Simulate processing delay
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // Validate donation amount
      if (amount < 1.0) {
        emit(
          state.copyWith(
            status: DonationStatus.failure,
            errorMessage: 'Minimum donation amount is ₹1.0',
          ),
        );
        return;
      }

      // In a real app, this would call a payment gateway
      // For now, we just simulate success

      // Update the node's donation amount in the flowchart
      final cubit = externalFlowchartCubit ?? flowchartCubit;

      if (cubit != null) {
        try {
          // Get the current donation amount for the node
          final currentNode = cubit.findNodeById(nodeId);
          if (currentNode != null) {
            final currentDonation = currentNode.donation;
            final newDonation = currentDonation + amount;

            // Update the node's donation amount
            await cubit.updateNodeDonation(nodeId, newDonation);

            debugPrint(
              'Updated donation for node $nodeId: '
              '$currentDonation -> $newDonation',
            );
          } else {
            debugPrint('Node not found: $nodeId');
          }
        } catch (e) {
          debugPrint('Error updating node donation: $e');
          // Continue with success state even if flowchart update fails
          // The donation was processed successfully
        }
      } else {
        debugPrint('No FlowchartCubit available to update node donation');
      }

      // Emit success state
      emit(
        state.copyWith(
          status: DonationStatus.success,
        ),
      );
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'DonationCubit.processDonation',
      );

      // Emit failure state
      emit(
        state.copyWith(
          status: DonationStatus.failure,
          errorMessage: 'Failed to process donation: $e',
        ),
      );
    }
  }
}
