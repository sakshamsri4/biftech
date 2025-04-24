import 'package:biftech/features/donation/donation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDonationCubit extends Mock implements DonationCubit {}

void main() {
  group('DonationModal', () {
    late MockDonationCubit mockDonationCubit;

    setUp(() {
      mockDonationCubit = MockDonationCubit();

      when(() => mockDonationCubit.state).thenReturn(DonationState.initial);
    });

    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationModal(
              nodeId: 'test_node_id',
              nodeText: 'Test node text', // Added required argument
              currentDonation: 0, // Added required argument
              onDonationComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('💰 Make a Donation'), findsOneWidget);
      expect(
        find.text('Support this argument with a donation'),
        findsOneWidget,
      );
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Donate'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('validates minimum donation amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonationModal(
              nodeId: 'test_node_id',
              nodeText: 'Test node text', // Added required argument
              currentDonation: 0, // Added required argument
              onDonationComplete: (_) {},
            ),
          ),
        ),
      );

      // Enter an invalid amount
      await tester.enterText(find.byType(TextFormField), '0.5');

      // Tap the donate button
      await tester.tap(find.text('Donate'));
      await tester.pump();

      // Expect validation error
      expect(find.text('Min ₹1.0'), findsOneWidget);
    });

    testWidgets('calls processDonation when form is valid', (tester) async {
      // Set up a mock cubit that will be provided to the widget
      when(
        () => mockDonationCubit.processDonation(
          nodeId: any(named: 'nodeId'),
          amount: any(named: 'amount'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<DonationCubit>.value(
              value: mockDonationCubit,
              child: DonationModal(
                nodeId: 'test_node_id',
                nodeText: 'Test node text', // Added required argument
                currentDonation: 0, // Added required argument
                onDonationComplete: (_) {},
              ),
            ),
          ),
        ),
      );

      // Enter a valid amount
      await tester.enterText(find.byType(TextFormField), '10.0');

      // Tap the donate button
      await tester.tap(find.text('Donate'));
      await tester.pump();

      // Verify that processDonation was called with the correct parameters
      verify(
        () => mockDonationCubit.processDonation(
          nodeId: 'test_node_id',
          amount: 10,
        ),
      ).called(1);
    });

    testWidgets(
        'closes modal and calls onDonationComplete when donation succeeds',
        (tester) async {
      // Set up a mock cubit that will emit success
      const successState = DonationState(
        status: DonationStatus.success,
        amount: 10,
        nodeId: 'test_node_id',
      );

      when(() => mockDonationCubit.state).thenReturn(successState);

      var donationCompleted = false;
      var donationAmount = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<DonationCubit>.value(
              value: mockDonationCubit,
              child: DonationModal(
                nodeId: 'test_node_id',
                nodeText: 'Test node text', // Added required argument
                currentDonation: 0, // Added required argument
                onDonationComplete: (amount) {
                  donationCompleted = true;
                  donationAmount = amount;
                },
              ),
            ),
          ),
        ),
      );

      // Simulate the cubit emitting a success state
      final cubitState = mockDonationCubit.state;
      when(() => mockDonationCubit.state).thenReturn(
        cubitState.copyWith(
          status: DonationStatus.success,
          amount: 10,
        ),
      );

      // Rebuild the widget with the new state
      await tester.pump();

      // Verify that onDonationComplete was called with the correct amount
      expect(donationCompleted, isTrue);
      expect(donationAmount, equals(10.0));
    });
  });
}
