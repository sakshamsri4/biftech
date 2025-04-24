import 'package:biftech/features/donation/donation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DonationCubit', () {
    late DonationCubit donationCubit;

    setUp(() {
      donationCubit = DonationCubit();
    });

    tearDown(() {
      donationCubit.close();
    });

    test('initial state is correct', () {
      expect(donationCubit.state, equals(DonationState.initial));
    });

    blocTest<DonationCubit, DonationState>(
      'emits [loading, success] when processDonation succeeds',
      build: () => donationCubit,
      act: (cubit) => cubit.processDonation(
        nodeId: 'test_node_id',
        amount: 10,
      ),
      wait: const Duration(milliseconds: 1000),
      expect: () => [
        isA<DonationState>().having(
          (state) => state.status,
          'status',
          DonationStatus.loading,
        ),
        isA<DonationState>().having(
          (state) => state.status,
          'status',
          DonationStatus.success,
        ),
      ],
    );

    blocTest<DonationCubit, DonationState>(
      'emits [loading, failure] when amount is less than minimum',
      build: () => donationCubit,
      act: (cubit) => cubit.processDonation(
        nodeId: 'test_node_id',
        amount: 0.5,
      ),
      wait: const Duration(milliseconds: 1000),
      expect: () => [
        isA<DonationState>().having(
          (state) => state.status,
          'status',
          DonationStatus.loading,
        ),
        isA<DonationState>()
            .having(
              (state) => state.status,
              'status',
              DonationStatus.failure,
            )
            .having(
              (state) => state.errorMessage,
              'errorMessage',
              contains('Minimum donation amount'),
            ),
      ],
    );
  });
}
