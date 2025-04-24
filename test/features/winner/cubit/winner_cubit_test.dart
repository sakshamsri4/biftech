import 'package:biftech/features/flowchart/cubit/flowchart_cubit.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/features/winner/cubit/winner_cubit.dart';
import 'package:biftech/features/winner/cubit/winner_state.dart';
import 'package:biftech/features/winner/model/winner_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlowchartCubit extends Mock implements FlowchartCubit {}

void main() {
  group('WinnerCubit', () {
    late WinnerCubit winnerCubit;
    late MockFlowchartCubit mockFlowchartCubit;

    setUp(() {
      mockFlowchartCubit = MockFlowchartCubit();
      winnerCubit = WinnerCubit(flowchartCubit: mockFlowchartCubit);
    });

    tearDown(() {
      winnerCubit.close();
    });

    test('initial state is WinnerState.initial', () {
      expect(winnerCubit.state, equals(WinnerState.initial));
    });

    group('declareWinner', () {
      final winningNode = NodeModel(
        id: 'node1',
        text: 'Test Node',
        donation: 100,
        comments: const [
          'Test Comment by Test Author',
          'Test Comment 2 by Test Author 2',
        ],
      );

      test('emits [loading, waiting] when successful', () async {
        // Arrange
        when(() => mockFlowchartCubit.findWinningNode())
            .thenReturn(winningNode);
        when(() => mockFlowchartCubit.calculateTotalDonations())
            .thenReturn(100);

        // Act
        await winnerCubit.declareWinner();

        // Assert
        verify(() => mockFlowchartCubit.findWinningNode()).called(1);
        verify(() => mockFlowchartCubit.calculateTotalDonations()).called(1);

        expect(
          winnerCubit.state.status,
          equals(WinnerStatus.waiting),
        );
        expect(
          winnerCubit.state.winner,
          isA<WinnerModel>(),
        );
        expect(
          winnerCubit.state.winner?.winningNode,
          equals(winningNode),
        );
        expect(
          winnerCubit.state.winner?.totalDonations,
          equals(100),
        );
        expect(
          winnerCubit.state.winner?.winnerShare,
          equals(60), // 60% of 100
        );
        expect(
          winnerCubit.state.winner?.appShare,
          equals(20), // 20% of 100
        );
        expect(
          winnerCubit.state.winner?.platformShare,
          equals(20), // 20% of 100
        );
      });

      test('emits [loading, failure] when no winning node is found', () async {
        // Arrange
        when(() => mockFlowchartCubit.findWinningNode()).thenReturn(null);

        // Act
        await winnerCubit.declareWinner();

        // Assert
        verify(() => mockFlowchartCubit.findWinningNode()).called(1);
        verifyNever(() => mockFlowchartCubit.calculateTotalDonations());

        expect(
          winnerCubit.state.status,
          equals(WinnerStatus.failure),
        );
        expect(
          winnerCubit.state.error,
          equals('No winner found'),
        );
      });

      test('emits [loading, failure] when an exception is thrown', () async {
        // Arrange
        when(() => mockFlowchartCubit.findWinningNode())
            .thenThrow(Exception('Test Exception'));

        // Act
        await winnerCubit.declareWinner();

        // Assert
        verify(() => mockFlowchartCubit.findWinningNode()).called(1);
        verifyNever(() => mockFlowchartCubit.calculateTotalDonations());

        expect(
          winnerCubit.state.status,
          equals(WinnerStatus.failure),
        );
        expect(
          winnerCubit.state.error,
          contains('Failed to declare winner'),
        );
      });
    });

    group('cancelEvaluation', () {
      test('resets state to initial', () async {
        // Arrange
        final winningNode = NodeModel(
          id: 'node1',
          text: 'Test Node',
          donation: 100,
        );
        when(() => mockFlowchartCubit.findWinningNode())
            .thenReturn(winningNode);
        when(() => mockFlowchartCubit.calculateTotalDonations())
            .thenReturn(100);

        // First declare a winner to change the state
        await winnerCubit.declareWinner();
        expect(winnerCubit.state.status, equals(WinnerStatus.waiting));

        // Act
        winnerCubit.cancelEvaluation();

        // Assert
        expect(winnerCubit.state, equals(WinnerState.initial));
      });
    });

    group('60-20-20 distribution model', () {
      test('correctly distributes donations according to 60-20-20 model',
          () async {
        // Arrange
        final winningNode = NodeModel(
          id: 'node1',
          text: 'Test Node',
          donation: 100,
        );
        when(() => mockFlowchartCubit.findWinningNode())
            .thenReturn(winningNode);

        // Test with different donation amounts
        const testAmounts = [100.0, 250.0, 500.0, 1000.0];

        for (final amount in testAmounts) {
          // Arrange
          when(() => mockFlowchartCubit.calculateTotalDonations())
              .thenReturn(amount);

          // Act
          await winnerCubit.declareWinner();

          // Assert
          expect(winnerCubit.state.winner?.totalDonations, equals(amount));
          expect(winnerCubit.state.winner?.winnerShare, equals(amount * 0.6));
          expect(winnerCubit.state.winner?.appShare, equals(amount * 0.2));
          expect(winnerCubit.state.winner?.platformShare, equals(amount * 0.2));

          // Verify that the sum of all shares equals the total donations
          final totalShares = winnerCubit.state.winner!.winnerShare +
              winnerCubit.state.winner!.appShare +
              winnerCubit.state.winner!.platformShare;

          expect(totalShares, equals(amount));
        }
      });
    });
  });
}
