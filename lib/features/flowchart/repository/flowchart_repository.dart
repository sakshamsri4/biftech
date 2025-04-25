import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Repository for managing flowchart data
class FlowchartRepository {
  /// Private constructor
  FlowchartRepository._internal();

  /// Singleton instance
  static final FlowchartRepository instance = FlowchartRepository._internal();

  /// Box for storing flowcharts
  Box<NodeModel>? _flowchartsBox;

  /// Initialize the repository
  Future<void> initialize() async {
    try {
      // Register the NodeModel adapter if not already registered
      if (!Hive.isAdapterRegistered(NodeModelAdapter().typeId)) {
        Hive.registerAdapter(NodeModelAdapter());
      }

      // Open the flowcharts box
      _flowchartsBox = await Hive.openBox<NodeModel>('flowcharts');
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartRepository.initialize',
      );
      rethrow;
    }
  }

  /// Get the flowchart for a video
  Future<NodeModel?> getFlowchartForVideo(String videoId) async {
    try {
      if (_flowchartsBox == null) {
        throw Exception('Flowcharts box is not initialized');
      }

      return _flowchartsBox!.get(videoId);
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartRepository.getFlowchartForVideo',
      );
      return null;
    }
  }

  /// Save a flowchart for a video
  Future<void> saveFlowchart(String videoId, NodeModel rootNode) async {
    try {
      debugPrint('\n\n🔍 FLOWCHART REPOSITORY - SAVE FLOWCHART START 🔍');
      debugPrint('📌 Video ID: $videoId');
      debugPrint('📌 Root Node ID: ${rootNode.id}');
      debugPrint('📌 Total Nodes: ${_countNodes(rootNode)}');

      if (_flowchartsBox == null) {
        debugPrint('⚠️ ERROR: Flowcharts box is not initialized');
        throw Exception('Flowcharts box is not initialized');
      }

      // Debug log to verify the flowchart structure before saving
      debugPrint('📊 FLOWCHART STRUCTURE BEFORE SAVING:');
      _logFlowchartStructure(rootNode);

      // Check if there's an existing flowchart
      final existingRootNode = _flowchartsBox!.get(videoId);
      if (existingRootNode != null) {
        debugPrint('📌 Found existing flowchart:');
        debugPrint('   - Root Node ID: ${existingRootNode.id}');
        debugPrint('   - Total Nodes: ${_countNodes(existingRootNode)}');

        // Compare node counts
        final existingNodeCount = _countNodes(existingRootNode);
        final newNodeCount = _countNodes(rootNode);
        debugPrint('📊 Node count comparison:');
        debugPrint('   - Existing: $existingNodeCount');
        debugPrint('   - New: $newNodeCount');
        debugPrint('   - Difference: ${newNodeCount - existingNodeCount}');
      } else {
        debugPrint('📌 No existing flowchart found for video $videoId');
      }

      // First, delete any existing flowchart to ensure clean state
      debugPrint('🔄 Deleting existing flowchart...');
      await _flowchartsBox!.delete(videoId);
      debugPrint('✅ Existing flowchart deleted');

      // Then save the new flowchart
      debugPrint('🔄 Saving new flowchart...');
      await _flowchartsBox!.put(videoId, rootNode);
      debugPrint('✅ New flowchart saved');

      // Verify the saved flowchart by reading it back
      final savedRootNode = _flowchartsBox!.get(videoId); // get is not async
      if (savedRootNode != null) {
        debugPrint('✅ Verified saved flowchart:');
        debugPrint('   - Root Node ID: ${savedRootNode.id}');
        debugPrint('   - Total Nodes: ${_countNodes(savedRootNode)}');

        // Verify all nodes are present
        final expectedNodeCount = _countNodes(rootNode);
        final actualNodeCount = _countNodes(savedRootNode);

        if (expectedNodeCount == actualNodeCount) {
          debugPrint('✅ Node count matches: $actualNodeCount');
        } else {
          debugPrint('⚠️ WARNING: Node count mismatch!');
          debugPrint('   - Expected: $expectedNodeCount');
          debugPrint('   - Actual: $actualNodeCount');
        }

        debugPrint('📊 SAVED FLOWCHART STRUCTURE:');
        _logFlowchartStructure(savedRootNode);
      } else {
        debugPrint('⚠️ WARNING: Failed to verify saved flowchart!');
        debugPrint('   - The flowchart was not found after saving');
      }

      debugPrint('🔍 FLOWCHART REPOSITORY - SAVE FLOWCHART END 🔍\n\n');
    } catch (e, stackTrace) {
      debugPrint('⚠️ ERROR in saveFlowchart: $e');
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartRepository.saveFlowchart',
      );
      debugPrint(
          '🔍 FLOWCHART REPOSITORY - SAVE FLOWCHART END (WITH ERROR) 🔍\n\n');
      rethrow;
    }
  }

  /// Helper method to count the total number of nodes in the tree
  int _countNodes(NodeModel node) {
    var count = 1; // Count this node

    // Add count from all challenges
    for (final challenge in node.challenges) {
      count += _countNodes(challenge);
    }

    return count;
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

  /// Delete a flowchart for a video
  Future<void> deleteFlowchart(String videoId) async {
    try {
      if (_flowchartsBox == null) {
        throw Exception('Flowcharts box is not initialized');
      }

      await _flowchartsBox!.delete(videoId);
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartRepository.deleteFlowchart',
      );
      rethrow;
    }
  }
}
