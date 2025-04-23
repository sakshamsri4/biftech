import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/donation/cubit/donation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing donation state
class DonationCubit extends Cubit<DonationState> {
  /// Constructor
  DonationCubit() : super(DonationState.initial);

  /// Process a donation
  Future<void> processDonation({
    required String nodeId,
    required double amount,
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
