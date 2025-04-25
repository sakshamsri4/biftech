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
      if (_flowchartsBox == null) {
        throw Exception('Flowcharts box is not initialized');
      }

      // Debug log to verify the flowchart structure before saving
      debugPrint('Saving flowchart for video $videoId:');
      _logFlowchartStructure(rootNode);

      // First, delete any existing flowchart to ensure clean state
      await _flowchartsBox!.delete(videoId);

      // Then save the new flowchart
      await _flowchartsBox!.put(videoId, rootNode);

      // Verify the saved flowchart by reading it back
      final savedRootNode = _flowchartsBox!.get(videoId); // get is not async
      if (savedRootNode != null) {
        debugPrint('Verified saved flowchart:');
        _logFlowchartStructure(savedRootNode);
      } else {
        debugPrint('WARNING: Failed to verify saved flowchart!');
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartRepository.saveFlowchart',
      );
      rethrow;
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
