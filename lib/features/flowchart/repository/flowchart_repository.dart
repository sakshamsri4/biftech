import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/model/models.dart';
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

      await _flowchartsBox!.put(videoId, rootNode);
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartRepository.saveFlowchart',
      );
      rethrow;
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
