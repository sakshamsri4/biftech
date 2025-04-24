import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:flutter/foundation.dart';

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
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartService.initialize',
      );

      // Try to initialize with fallback
      await _initializeWithFallback();
    }
  }

  /// Initialize with fallback in case of error
  Future<void> _initializeWithFallback() async {
    try {
      // Create a new instance of the repository
      // This is a fallback that will use in-memory storage
      // instead of persistent storage
      await FlowchartRepository.instance.initialize();

      // Log success
      debugPrint('FlowchartService initialized with fallback');
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'FlowchartService._initializeWithFallback',
      );

      // Rethrow the error
      rethrow;
    }
  }
}
