import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/cubit/flowchart_state.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing flowchart state
class FlowchartCubit extends Cubit<FlowchartState> {
  /// Constructor
  FlowchartCubit({
    required this.repository,
    required this.videoId,
  }) : super(FlowchartState.initial);

  /// Repository for flowchart data
  final FlowchartRepository repository;

  /// ID of the video this flowchart is for
  final String videoId;

  /// Load the flowchart for the current video
  Future<void> loadFlowchart() async {
    try {
      emit(state.copyWith(status: FlowchartStatus.loading));

      final rootNode = await repository.getFlowchartForVideo(videoId);

      if (rootNode == null) {
        // Create a new root node if none exists with some initial comments
        final newRootNode = NodeModel(
          id: 'root_$videoId',
          text: 'Discussion for video $videoId',
          comments: const [
            'This is an interesting topic!',
            'I agree with the main points.',
            'Great discussion starter!',
          ],
        );

        // Create a challenge node with comments
        final challengeNode = NodeModel(
          id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
          text: 'I have a different perspective on this topic.',
          comments: const [
            'Good point!',
            'I see what you mean.',
          ],
          donation: 25,
        );

        // Add the challenge to the root node
        final rootWithChallenge = newRootNode.addChallenge(challengeNode);

        // Save the flowchart with the root and challenge nodes
        await repository.saveFlowchart(videoId, rootWithChallenge);

        emit(
          state.copyWith(
            status: FlowchartStatus.success,
            rootNode: rootWithChallenge,
            expandedNodeIds: {rootWithChallenge.id, challengeNode.id},
          ),
        );
      } else {
        // Use existing root node
        emit(
          state.copyWith(
            status: FlowchartStatus.success,
            rootNode: rootNode,
            expandedNodeIds: {rootNode.id},
          ),
        );
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.loadFlowchart',
      );
      emit(
        state.copyWith(
          status: FlowchartStatus.failure,
          error: 'Failed to load flowchart: $e',
        ),
      );
    }
  }

  /// Toggle the expanded state of a node
  void toggleNodeExpanded(String nodeId) {
    final expandedNodeIds = Set<String>.from(state.expandedNodeIds);
    if (expandedNodeIds.contains(nodeId)) {
      expandedNodeIds.remove(nodeId);
    } else {
      expandedNodeIds.add(nodeId);
    }
    emit(state.copyWith(expandedNodeIds: expandedNodeIds));
  }

  /// Select a node
  void selectNode(String nodeId) {
    emit(state.copyWith(selectedNodeId: nodeId));
  }

  /// Add a comment to a node
  Future<void> addComment(String nodeId, String comment) async {
    try {
      if (state.rootNode == null) return;

      // Find the node and add the comment
      final updatedRootNode = _updateNodeInTree(
        state.rootNode!,
        nodeId,
        (node) => node.addComment(comment),
      );

      if (updatedRootNode != null) {
        // Save the updated flowchart
        await repository.saveFlowchart(videoId, updatedRootNode);

        // Update the state
        emit(state.copyWith(rootNode: updatedRootNode));
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.addComment',
      );
      emit(
        state.copyWith(
          status: FlowchartStatus.failure,
          error: 'Failed to add comment: $e',
        ),
      );
    }
  }

  /// Add a challenge to a node
  /// Returns the ID of the newly created challenge node
  Future<String> addChallenge(
    String parentNodeId,
    String text,
    double donation,
  ) async {
    try {
      if (state.rootNode == null) {
        throw Exception('Root node is null');
      }

      // Create a new challenge node
      final challengeNode = NodeModel(
        id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        donation: donation,
      );

      // Find the parent node and add the challenge
      final updatedRootNode = _updateNodeInTree(
        state.rootNode!,
        parentNodeId,
        (node) => node.addChallenge(challengeNode),
      );

      if (updatedRootNode != null) {
        // Save the updated flowchart
        await repository.saveFlowchart(videoId, updatedRootNode);

        // Update the state and expand the parent node
        final expandedNodeIds = Set<String>.from(state.expandedNodeIds)
          ..add(parentNodeId);

        emit(
          state.copyWith(
            rootNode: updatedRootNode,
            expandedNodeIds: expandedNodeIds,
          ),
        );

        // Return the ID of the new challenge node
        return challengeNode.id;
      } else {
        throw Exception('Failed to update root node');
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.addChallenge',
      );
      emit(
        state.copyWith(
          status: FlowchartStatus.failure,
          error: 'Failed to add challenge: $e',
        ),
      );
      // Re-throw the exception to ensure the method doesn't return null
      throw Exception('Failed to add challenge: $e');
    }
  }

  /// Find the winning node based on score (donation + comments)
  NodeModel? findWinningNode() {
    if (state.rootNode == null) return null;

    // Find the node with the highest score
    return _findNodeWithHighestScore(state.rootNode!);
  }

  /// Calculate the total donations in the flowchart
  double calculateTotalDonations() {
    if (state.rootNode == null) return 0;

    return _calculateTotalDonationsInTree(state.rootNode!);
  }

  /// Update the donation amount for a node
  Future<void> updateNodeDonation(String nodeId, double amount) async {
    try {
      if (state.rootNode == null) return;

      // Find the node and update its donation amount
      final updatedRootNode = _updateNodeInTree(
        state.rootNode!,
        nodeId,
        (node) => node.copyWith(donation: amount),
      );

      if (updatedRootNode != null) {
        // Save the updated flowchart
        await repository.saveFlowchart(videoId, updatedRootNode);

        // Update the state
        emit(state.copyWith(rootNode: updatedRootNode));
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.updateNodeDonation',
      );
      emit(
        state.copyWith(
          status: FlowchartStatus.failure,
          error: 'Failed to update donation: $e',
        ),
      );
    }
  }

  /// Helper method to update a node in the tree
  NodeModel? _updateNodeInTree(
    NodeModel node,
    String nodeId,
    NodeModel Function(NodeModel) updateFn,
  ) {
    // If this is the node to update, apply the update function
    if (node.id == nodeId) {
      return updateFn(node);
    }

    // Otherwise, recursively search the challenges
    final updatedChallenges = <NodeModel>[];
    var found = false;

    for (final challenge in node.challenges) {
      final updatedChallenge = _updateNodeInTree(
        challenge,
        nodeId,
        updateFn,
      );

      if (updatedChallenge != null) {
        updatedChallenges.add(updatedChallenge);
        found = true;
      } else {
        updatedChallenges.add(challenge);
      }
    }

    // If a node was updated in the challenges,
    // return a new node with updated challenges
    if (found) {
      return node.copyWith(challenges: updatedChallenges);
    }

    // If the node wasn't found in this branch, return null
    return null;
  }

  /// Helper method to find the node with the highest score
  NodeModel _findNodeWithHighestScore(NodeModel node) {
    var highestNode = node;
    var highestScore = node.score;

    // Recursively check all challenges
    for (final challenge in node.challenges) {
      final winningNode = _findNodeWithHighestScore(challenge);
      if (winningNode.score > highestScore) {
        highestNode = winningNode;
        highestScore = winningNode.score;
      } else if (winningNode.score == highestScore) {
        // Tiebreaker: earlier creation time wins
        if (winningNode.createdAt.isBefore(highestNode.createdAt)) {
          highestNode = winningNode;
        }
      }
    }

    return highestNode;
  }

  /// Helper method to calculate total donations in the tree
  double _calculateTotalDonationsInTree(NodeModel node) {
    var total = node.donation;

    // Add donations from all challenges
    for (final challenge in node.challenges) {
      total += _calculateTotalDonationsInTree(challenge);
    }

    return total;
  }
}
