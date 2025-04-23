import 'package:flutter/foundation.dart';

/// Service for logging errors in the application
class ErrorLoggingService {
  /// Private constructor for singleton pattern
  ErrorLoggingService._();

  /// Singleton instance
  static final ErrorLoggingService _instance = ErrorLoggingService._();

  /// Get the singleton instance
  static ErrorLoggingService get instance => _instance;

  /// Log an error with optional stack trace and context
  void logError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    // In a real app,
    //you might send this to a service like Firebase Crashlytics,
    // Sentry, or your own backend

    // For now, just print to console in debug mode
    if (kDebugMode) {
      print('ERROR${context != null ? ' [$context]' : ''}: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  /// Log a warning message
  void logWarning(String message, {String? context}) {
    // In a real app, you might send this to a logging service

    // For now, just print to console in debug mode
    if (kDebugMode) {
      print('WARNING${context != null ? ' [$context]' : ''}: $message');
    }
  }

  /// Log an info message
  void logInfo(String message, {String? context}) {
    // In a real app, you might send this to a logging service

    // For now, just print to console in debug mode
    if (kDebugMode) {
      print('INFO${context != null ? ' [$context]' : ''}: $message');
    }
  }
}
