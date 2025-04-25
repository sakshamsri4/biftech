import 'dart:async';

import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/cubit/flowchart_state.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing flowchart state
class FlowchartCubit extends Cubit<FlowchartState> {
  /// Constructor
  FlowchartCubit({
    required this.repository,
    required this.videoId,
  }) : super(FlowchartState.initial) {
    // Initialize the comment stream controller
    _commentStreamController = StreamController<void>.broadcast();
    commentStream = _commentStreamController.stream;
  }

  /// The BuildContext from the FlowchartPage
  BuildContext? context;

  /// Stream controller for comment events
  late final StreamController<void> _commentStreamController;

  /// Stream of comment events that can be listened to
  late final Stream<void> commentStream;

  @override
  Future<void> close() {
    _commentStreamController.close();
    return super.close();
  }

  /// Repository for flowchart data
  final FlowchartRepository repository;

  /// ID of the video this flowchart is for
  final String videoId;

  /// Load the flowchart for the current video
  Future<void> loadFlowchart() async {
    try {
      if (isClosed) return;
      emit(state.copyWith(status: FlowchartStatus.loading));

      final rootNode = await repository.getFlowchartForVideo(videoId);
      if (isClosed) return;

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

        // Create first challenge node with comments
        final challenge1 = NodeModel(
          id: 'challenge_${DateTime.now().millisecondsSinceEpoch}_1',
          text: 'I have a different perspective on this topic.',
          comments: const [
            'Good point!',
            'I see what you mean.',
          ],
          donation: 25,
        );

        // Create second challenge node with comments
        final challenge2 = NodeModel(
          id: 'challenge_${DateTime.now().millisecondsSinceEpoch}_2',
          text: 'I think we should consider the environmental impact.',
          comments: const [
            'Absolutely!',
            'The environment is a critical factor.',
          ],
          donation: 15,
        );

        // Create a sub-challenge under challenge1
        final subChallenge1 = NodeModel(
          id: 'challenge_${DateTime.now().millisecondsSinceEpoch}_1_1',
          text: 'Research shows alternative approaches are more effective.',
          comments: const [
            'Can you share that research?',
            'Interesting finding!',
          ],
          donation: 10,
        );

        // Add the sub-challenge to challenge1
        final challenge1WithSubChallenge =
            challenge1.addChallenge(subChallenge1);

        // Add both challenges to the root node
        var rootWithChallenges =
            newRootNode.addChallenge(challenge1WithSubChallenge);
        rootWithChallenges = rootWithChallenges.addChallenge(challenge2);

        // Save the flowchart with the root and challenge nodes
        await repository.saveFlowchart(videoId, rootWithChallenges);
        if (isClosed) return;

        emit(
          state.copyWith(
            status: FlowchartStatus.success,
            rootNode: rootWithChallenges,
            expandedNodeIds: {
              rootWithChallenges.id,
              challenge1WithSubChallenge.id,
              challenge2.id,
              subChallenge1.id,
            },
          ),
        );

        // Debug log to verify the initial flowchart structure
        debugPrint(
          'Created initial flowchart with '
          '${_countNodesInTree(rootWithChallenges)} nodes',
        );
        _logFlowchartStructure(rootWithChallenges);
      } else {
        // Use existing root node
        // Debug log to verify the loaded flowchart structure
        debugPrint(
          'Loaded existing flowchart with '
          '${_countNodesInTree(rootNode)} nodes',
        );
        _logFlowchartStructure(rootNode);

        // Expand all nodes for better visibility
        final expandedNodeIds = <String>{rootNode.id};
        _collectAllNodeIds(rootNode, expandedNodeIds);

        emit(
          state.copyWith(
            status: FlowchartStatus.success,
            rootNode: rootNode,
            expandedNodeIds: expandedNodeIds,
          ),
        );
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.loadFlowchart',
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FlowchartStatus.failure,
          error: 'Failed to load flowchart: $e',
        ),
      );
    }
  }

  /// Helper method to collect all node IDs in the tree
  void _collectAllNodeIds(NodeModel node, Set<String> nodeIds) {
    nodeIds.add(node.id);
    for (final challenge in node.challenges) {
      _collectAllNodeIds(challenge, nodeIds);
    }
  }

  /// Helper method to log the flowchart structure
  void _logFlowchartStructure(NodeModel rootNode, [String indent = '']) {
    debugPrint(
      '$indent- ${rootNode.id}: "${rootNode.text}" '
      '(${rootNode.challenges.length} challenges)',
    );
    for (final challenge in rootNode.challenges) {
      _logFlowchartStructure(challenge, '$indent  ');
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
      if (isClosed) return;
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
        if (isClosed) return;

        // Update the state
        emit(state.copyWith(rootNode: updatedRootNode));

        // Notify listeners that a comment was added
        notifyCommentAdded();
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.addComment',
      );
      if (isClosed) return;
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
      debugPrint('\n\n🔍 FLOWCHART CUBIT - ADD CHALLENGE START 🔍');
      debugPrint('📌 Parent Node ID: $parentNodeId');
      debugPrint('📌 Challenge Text: "$text"');
      debugPrint('📌 Donation Amount: ₹$donation');

      if (isClosed) {
        debugPrint('⚠️ ERROR: Cubit is closed');
        throw Exception('Cubit is closed');
      }

      if (state.rootNode == null) {
        debugPrint('⚠️ ERROR: Root node is null');
        throw Exception('Root node is null');
      }

      // Log the current state
      debugPrint('📊 Current FlowchartState:');
      debugPrint('   - Status: ${state.status}');
      debugPrint('   - Selected Node ID: ${state.selectedNodeId}');
      debugPrint('   - Root Node ID: ${state.rootNode!.id}');
      debugPrint('   - Total Nodes: ${_countNodesInTree(state.rootNode!)}');

      // Create a new challenge node with a unique timestamp-based ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final challengeNodeId = 'challenge_$timestamp';
      debugPrint('📌 Generated new challenge ID: $challengeNodeId');

      final challengeNode = NodeModel(
        id: challengeNodeId,
        text: text,
        donation: donation,
      );

      debugPrint('📌 Created new NodeModel:');
      debugPrint('   - ID: ${challengeNode.id}');
      debugPrint('   - Text: "${challengeNode.text}"');
      debugPrint('   - Donation: ₹${challengeNode.donation}');
      debugPrint('   - Created At: ${challengeNode.createdAt}');

      // Log the parent node before adding the challenge
      final parentNode = findNodeById(parentNodeId);
      if (parentNode != null) {
        debugPrint('📌 Found parent node:');
        debugPrint('   - ID: ${parentNode.id}');
        debugPrint('   - Text: "${parentNode.text}"');
        debugPrint('   - Current Challenges: ${parentNode.challenges.length}');
        if (parentNode.challenges.isNotEmpty) {
          debugPrint('   - Existing Challenge IDs:');
          for (final challenge in parentNode.challenges) {
            debugPrint('     * ${challenge.id}');
          }
        }
      } else {
        debugPrint('⚠️ ERROR: Parent node not found: $parentNodeId');
        throw Exception('Parent node not found: $parentNodeId');
      }

      // Log the flowchart structure before the update
      debugPrint('📊 FLOWCHART STRUCTURE BEFORE:');
      _logFlowchartStructure(state.rootNode!);

      // Find the parent node and add the challenge
      debugPrint('🔄 Calling _updateNodeInTree to add challenge...');
      final updatedRootNode = _updateNodeInTree(
        state.rootNode!,
        parentNodeId,
        (node) {
          debugPrint('🔄 Adding challenge to node ${node.id}');
          final updatedNode = node.addChallenge(challengeNode);
          debugPrint(
              '🔄 Node updated, now has ${updatedNode.challenges.length} challenges');
          return updatedNode;
        },
      );

      if (updatedRootNode != null) {
        debugPrint('✅ Root node updated successfully');

        // Verify the challenge was added by finding the parent node again
        final updatedParentNode =
            _findNodeInTree(updatedRootNode, parentNodeId);
        if (updatedParentNode != null) {
          debugPrint('📌 Updated parent node:');
          debugPrint('   - ID: ${updatedParentNode.id}');
          debugPrint(
              '   - Challenges Count: ${updatedParentNode.challenges.length}');

          // Check if the challenge is actually in the parent's challenges
          final challengeExists = updatedParentNode.challenges.any(
            (c) => c.id == challengeNode.id,
          );

          if (challengeExists) {
            debugPrint('✅ Challenge successfully added to parent node');
            debugPrint('   - Challenge IDs in parent:');
            for (final challenge in updatedParentNode.challenges) {
              debugPrint('     * ${challenge.id}');
            }
          } else {
            debugPrint(
                '⚠️ ERROR: Challenge was not properly added to parent node!');
            debugPrint('   - Challenge ID: ${challengeNode.id}');
            debugPrint('   - Parent Node ID: ${updatedParentNode.id}');
            debugPrint('   - Parent Node Challenges:');
            for (final challenge in updatedParentNode.challenges) {
              debugPrint('     * ${challenge.id}');
            }
            throw Exception('Challenge was not properly added to parent node');
          }
        } else {
          debugPrint('⚠️ ERROR: Updated parent node not found after update!');
          throw Exception('Updated parent node not found after update');
        }

        // Log the flowchart structure after the update
        debugPrint('📊 FLOWCHART STRUCTURE AFTER UPDATE:');
        _logFlowchartStructure(updatedRootNode);

        // Save the updated flowchart
        debugPrint('🔄 Saving updated flowchart to repository...');
        await repository.saveFlowchart(videoId, updatedRootNode);
        debugPrint('✅ Flowchart saved to repository');

        if (isClosed) {
          debugPrint('⚠️ ERROR: Cubit closed during save');
          throw Exception('Cubit closed during save');
        }

        // Update the state and expand all nodes for better visibility
        final expandedNodeIds = <String>{};
        _collectAllNodeIds(updatedRootNode, expandedNodeIds);
        debugPrint(
            '📌 Collected ${expandedNodeIds.length} node IDs for expansion');

        // Force a reload of the flowchart to ensure the UI updates
        debugPrint('🔄 Emitting updated state with new challenge...');
        emit(
          state.copyWith(
            rootNode: updatedRootNode,
            expandedNodeIds: expandedNodeIds,
            // Select the new challenge node to highlight it
            selectedNodeId: challengeNode.id,
          ),
        );
        debugPrint('✅ State updated with new challenge');

        // Debug log to verify the challenge was added
        debugPrint('📊 SUMMARY:');
        debugPrint('   - Added challenge: ${challengeNode.id}');
        debugPrint('   - To parent: $parentNodeId');
        debugPrint(
            '   - Updated root node has ${_countNodesInTree(updatedRootNode)} nodes');

        // Log the full flowchart structure after adding the challenge
        debugPrint('📊 FINAL FLOWCHART STRUCTURE:');
        _logFlowchartStructure(updatedRootNode);

        debugPrint('🔍 FLOWCHART CUBIT - ADD CHALLENGE END 🔍\n\n');

        // Return the ID of the new challenge node
        return challengeNode.id;
      } else {
        debugPrint('⚠️ ERROR: Failed to update root node');
        throw Exception('Failed to update root node');
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ ERROR in addChallenge: $e');
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.addChallenge',
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            status: FlowchartStatus.failure,
            error: 'Failed to add challenge: $e',
          ),
        );
      }
      debugPrint('🔍 FLOWCHART CUBIT - ADD CHALLENGE END (WITH ERROR) 🔍\n\n');
      throw Exception('Failed to add challenge: $e');
    }
  }

  /// Helper method to count the total number of nodes in the tree
  int _countNodesInTree(NodeModel node) {
    var count = 1; // Count this node

    // Add count from all challenges
    for (final challenge in node.challenges) {
      count += _countNodesInTree(challenge);
    }

    return count;
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
      if (isClosed) return;
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
        if (isClosed) return;

        // Update the state
        emit(state.copyWith(rootNode: updatedRootNode));
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartCubit.updateNodeDonation',
      );
      if (isClosed) return;
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
      final updatedNode = updateFn(node);
      debugPrint(
        'Node ${node.id} updated: challenges '
        'before=${node.challenges.length}, '
        'after=${updatedNode.challenges.length}',
      );
      return updatedNode;
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
      final updatedNode = node.copyWith(challenges: updatedChallenges);
      debugPrint('Propagating update through node ${node.id}');
      return updatedNode;
    }

    // If the node wasn't found in this branch, return null
    return null;
  }

  /// Find a node by its ID
  NodeModel? findNodeById(String nodeId) {
    if (state.rootNode == null) return null;
    return _findNodeInTree(state.rootNode!, nodeId);
  }

  /// Helper method to find a node in the tree by its ID
  NodeModel? _findNodeInTree(NodeModel node, String nodeId) {
    // If this is the node we're looking for, return it
    if (node.id == nodeId) {
      return node;
    }

    // Otherwise, recursively search the challenges
    for (final challenge in node.challenges) {
      final foundNode = _findNodeInTree(challenge, nodeId);
      if (foundNode != null) {
        return foundNode;
      }
    }

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

  /// Notify listeners that a comment was added
  void notifyCommentAdded() {
    if (!_commentStreamController.isClosed) {
      _commentStreamController.add(null);
    }
  }
}
