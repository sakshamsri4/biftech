import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlowchartRepository extends Mock implements FlowchartRepository {}

class FakeNodeModel extends Fake implements NodeModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNodeModel());
  });
  group('FlowchartCubit', () {
    late FlowchartRepository repository;
    late FlowchartCubit cubit;
    const videoId = 'test_video_id';

    setUp(() {
      repository = MockFlowchartRepository();
      cubit = FlowchartCubit(
        repository: repository,
        videoId: videoId,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is FlowchartState.initial', () {
      expect(cubit.state, equals(FlowchartState.initial));
    });

    group('loadFlowchart', () {
      final rootNode = NodeModel(
        id: 'root',
        text: 'Test Root Node',
        comments: const ['Comment 1'],
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'emits [loading, success] when repository returns a node',
        build: () {
          when(() => repository.getFlowchartForVideo(videoId))
              .thenAnswer((_) async => rootNode);
          return cubit;
        },
        act: (cubit) => cubit.loadFlowchart(),
        expect: () => [
          const FlowchartState(status: FlowchartStatus.loading),
          FlowchartState(
            status: FlowchartStatus.success,
            rootNode: rootNode,
            expandedNodeIds: {rootNode.id},
          ),
        ],
        verify: (_) {
          verify(() => repository.getFlowchartForVideo(videoId)).called(1);
        },
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'creates a new root node when repository returns null',
        build: () {
          when(() => repository.getFlowchartForVideo(videoId))
              .thenAnswer((_) async => null);
          when(() => repository.saveFlowchart(any(), any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.loadFlowchart(),
        expect: () => [
          const FlowchartState(status: FlowchartStatus.loading),
          isA<FlowchartState>()
              .having((s) => s.status, 'status', FlowchartStatus.success)
              .having((s) => s.rootNode?.id, 'rootNode.id', contains(videoId))
              .having(
                (s) => s.expandedNodeIds,
                'expandedNodeIds',
                isA<Set<String>>().having(
                  (set) => set.length,
                  'length',
                  1,
                ),
              ),
        ],
        verify: (_) {
          verify(() => repository.getFlowchartForVideo(videoId)).called(1);
          verify(() => repository.saveFlowchart(videoId, any())).called(1);
        },
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'emits [loading, failure] when repository throws',
        build: () {
          when(() => repository.getFlowchartForVideo(videoId))
              .thenThrow(Exception('Test error'));
          return cubit;
        },
        act: (cubit) => cubit.loadFlowchart(),
        expect: () => [
          const FlowchartState(status: FlowchartStatus.loading),
          isA<FlowchartState>()
              .having((s) => s.status, 'status', FlowchartStatus.failure)
              .having(
                (s) => s.error,
                'error',
                contains('Failed to load flowchart'),
              ),
        ],
        verify: (_) {
          verify(() => repository.getFlowchartForVideo(videoId)).called(1);
        },
      );
    });

    group('toggleNodeExpanded', () {
      blocTest<FlowchartCubit, FlowchartState>(
        'adds node ID to expandedNodeIds when not expanded',
        build: () => cubit,
        seed: () => const FlowchartState(
          status: FlowchartStatus.success,
          expandedNodeIds: {'node1'},
        ),
        act: (cubit) => cubit.toggleNodeExpanded('node2'),
        expect: () => [
          const FlowchartState(
            status: FlowchartStatus.success,
            expandedNodeIds: {'node1', 'node2'},
          ),
        ],
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'removes node ID from expandedNodeIds when already expanded',
        build: () => cubit,
        seed: () => const FlowchartState(
          status: FlowchartStatus.success,
          expandedNodeIds: {'node1', 'node2'},
        ),
        act: (cubit) => cubit.toggleNodeExpanded('node2'),
        expect: () => [
          const FlowchartState(
            status: FlowchartStatus.success,
            expandedNodeIds: {'node1'},
          ),
        ],
      );
    });

    group('selectNode', () {
      blocTest<FlowchartCubit, FlowchartState>(
        'updates selectedNodeId',
        build: () => cubit,
        seed: () => const FlowchartState(
          status: FlowchartStatus.success,
          selectedNodeId: 'node1',
        ),
        act: (cubit) => cubit.selectNode('node2'),
        expect: () => [
          const FlowchartState(
            status: FlowchartStatus.success,
            selectedNodeId: 'node2',
          ),
        ],
      );
    });

    group('addComment', () {
      final rootNode = NodeModel(
        id: 'root',
        text: 'Root Node',
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'adds comment to the node and saves to repository',
        build: () {
          when(() => repository.saveFlowchart(any(), any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        seed: () => FlowchartState(
          status: FlowchartStatus.success,
          rootNode: rootNode,
        ),
        act: (cubit) => cubit.addComment('root', 'Test Comment'),
        expect: () => [
          isA<FlowchartState>()
              .having((s) => s.status, 'status', FlowchartStatus.success)
              .having(
                (s) => s.rootNode?.comments,
                'rootNode.comments',
                equals(['Test Comment']),
              ),
        ],
        verify: (_) {
          verify(() => repository.saveFlowchart(videoId, any())).called(1);
        },
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'does nothing if rootNode is null',
        build: () => cubit,
        seed: () => const FlowchartState(
          status: FlowchartStatus.success,
        ),
        act: (cubit) => cubit.addComment('root', 'Test Comment'),
        expect: () => <FlowchartState>[],
        verify: (_) {
          verifyNever(() => repository.saveFlowchart(any(), any()));
        },
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'emits failure state when repository throws',
        build: () {
          when(() => repository.saveFlowchart(any(), any()))
              .thenThrow(Exception('Test error'));
          return cubit;
        },
        seed: () => FlowchartState(
          status: FlowchartStatus.success,
          rootNode: rootNode,
        ),
        act: (cubit) => cubit.addComment('root', 'Test Comment'),
        expect: () => [
          isA<FlowchartState>()
              .having((s) => s.status, 'status', FlowchartStatus.failure)
              .having(
                (s) => s.error,
                'error',
                contains('Failed to add comment'),
              ),
        ],
        verify: (_) {
          verify(() => repository.saveFlowchart(videoId, any())).called(1);
        },
      );
    });

    group('addChallenge', () {
      final rootNode = NodeModel(
        id: 'root',
        text: 'Root Node',
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'adds challenge to the node and saves to repository',
        build: () {
          when(() => repository.saveFlowchart(any(), any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        seed: () => FlowchartState(
          status: FlowchartStatus.success,
          rootNode: rootNode,
        ),
        act: (cubit) => cubit.addChallenge('root', 'Test Challenge', 10),
        expect: () => [
          isA<FlowchartState>()
              .having((s) => s.status, 'status', FlowchartStatus.success)
              .having(
                (s) => s.rootNode?.challenges.length,
                'rootNode.challenges.length',
                equals(1),
              )
              .having(
                (s) => s.rootNode?.challenges.first.text,
                'rootNode.challenges.first.text',
                equals('Test Challenge'),
              )
              .having(
                (s) => s.rootNode?.challenges.first.donation,
                'rootNode.challenges.first.donation',
                equals(10),
              )
              .having(
                (s) => s.expandedNodeIds,
                'expandedNodeIds',
                contains('root'),
              ),
        ],
        verify: (_) {
          verify(() => repository.saveFlowchart(videoId, any())).called(1);
        },
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'does nothing if rootNode is null',
        build: () => cubit,
        seed: () => const FlowchartState(
          status: FlowchartStatus.success,
        ),
        act: (cubit) => cubit.addChallenge('root', 'Test Challenge', 10),
        expect: () => <FlowchartState>[],
        verify: (_) {
          verifyNever(() => repository.saveFlowchart(any(), any()));
        },
      );

      blocTest<FlowchartCubit, FlowchartState>(
        'emits failure state when repository throws',
        build: () {
          when(() => repository.saveFlowchart(any(), any()))
              .thenThrow(Exception('Test error'));
          return cubit;
        },
        seed: () => FlowchartState(
          status: FlowchartStatus.success,
          rootNode: rootNode,
        ),
        act: (cubit) => cubit.addChallenge('root', 'Test Challenge', 10),
        expect: () => [
          isA<FlowchartState>()
              .having((s) => s.status, 'status', FlowchartStatus.failure)
              .having(
                (s) => s.error,
                'error',
                contains('Failed to add challenge'),
              ),
        ],
        verify: (_) {
          verify(() => repository.saveFlowchart(videoId, any())).called(1);
        },
      );
    });

    group('findWinningNode', () {
      test('returns null if rootNode is null', () {
        expect(cubit.findWinningNode(), isNull);
      });

      test('returns node with highest score', () {
        final challenge1 = NodeModel(
          id: 'challenge1',
          text: 'Challenge 1',
          donation: 10,
          comments: const ['Comment 1'],
          createdAt: DateTime(2023, 4, 25), // Earlier date
        );
        final challenge2 = NodeModel(
          id: 'challenge2',
          text: 'Challenge 2',
          donation: 5,
          comments: const ['Comment 1', 'Comment 2', 'Comment 3'],
          createdAt: DateTime(2023, 4, 26), // Later date
        );
        final rootNode = NodeModel(
          id: 'root',
          text: 'Root Node',
          comments: const ['Comment 1', 'Comment 2'],
          challenges: [challenge1, challenge2],
        );

        cubit = FlowchartCubit(
          repository: repository,
          videoId: videoId,
        )..emit(
            FlowchartState(
              status: FlowchartStatus.success,
              rootNode: rootNode,
            ),
          );

        final winningNode = cubit.findWinningNode();
        expect(winningNode, isNotNull);
        // Challenge2 has higher score: 5 donation + 3 comments = 8
        // Challenge1 has lower score: 10 donation + 1 comment = 11
        expect(winningNode?.id, equals('challenge1'));
        expect(winningNode?.score, equals(11)); // 10 donation + 1 comment
      });

      test('uses createdAt as tiebreaker', () {
        final earlier = DateTime(2023, 4, 25);
        final later = DateTime(2023, 4, 26);

        final challenge1 = NodeModel(
          id: 'challenge1',
          text: 'Challenge 1',
          donation: 5,
          comments: const ['Comment 1'],
          createdAt: earlier,
        );
        final challenge2 = NodeModel(
          id: 'challenge2',
          text: 'Challenge 2',
          donation: 5,
          comments: const ['Comment 1'],
          createdAt: later,
        );
        final rootNode = NodeModel(
          id: 'root',
          text: 'Root Node',
          challenges: [challenge1, challenge2],
        );

        cubit = FlowchartCubit(
          repository: repository,
          videoId: videoId,
        )..emit(
            FlowchartState(
              status: FlowchartStatus.success,
              rootNode: rootNode,
            ),
          );

        final winningNode = cubit.findWinningNode();
        expect(winningNode, isNotNull);
        expect(winningNode?.id, equals('challenge1'));
        expect(winningNode?.createdAt, equals(earlier));
      });
    });

    group('calculateTotalDonations', () {
      test('returns 0 if rootNode is null', () {
        expect(cubit.calculateTotalDonations(), equals(0));
      });

      test('calculates total donations in the tree', () {
        final challenge1 = NodeModel(
          id: 'challenge1',
          text: 'Challenge 1',
          donation: 10,
        );
        final challenge2 = NodeModel(
          id: 'challenge2',
          text: 'Challenge 2',
          donation: 5,
          challenges: [
            NodeModel(
              id: 'challenge2_1',
              text: 'Challenge 2.1',
              donation: 15,
            ),
          ],
        );
        final rootNode = NodeModel(
          id: 'root',
          text: 'Root Node',
          challenges: [challenge1, challenge2],
        );

        cubit = FlowchartCubit(
          repository: repository,
          videoId: videoId,
        )..emit(
            FlowchartState(
              status: FlowchartStatus.success,
              rootNode: rootNode,
            ),
          );

        final totalDonations = cubit.calculateTotalDonations();
        expect(totalDonations, equals(30)); // 0 + 10 + 5 + 15
      });
    });
  });
}
