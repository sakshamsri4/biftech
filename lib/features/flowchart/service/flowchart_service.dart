import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';

/// Service for initializing flowchart functionality
class FlowchartService {
  /// Private constructor
  FlowchartService._internal();

  /// Singleton instance
  static final FlowchartService instance = FlowchartService._internal();

  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Initialize the repository
      await FlowchartRepository.instance.initialize();
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartService.initialize',
      );
      rethrow;
    }
  }
}
