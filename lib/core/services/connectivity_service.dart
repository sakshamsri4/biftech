import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to check and monitor network connectivity
class ConnectivityService {
  /// Singleton instance
  static final ConnectivityService instance = ConnectivityService._internal();

  /// Private constructor
  ConnectivityService._internal() {
    _initialize();
  }

  /// Connectivity instance
  final Connectivity _connectivity = Connectivity();

  /// Stream controller for connectivity changes
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// Current connection status
  bool _hasConnection = true;

  /// Stream of connection status changes
  Stream<bool> get connectionStream => _connectionStatusController.stream;

  /// Current connection status
  bool get hasConnection => _hasConnection;

  /// Initialize the service
  void _initialize() {
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Check initial connection status
    checkConnection();
  }

  /// Check current connection status
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _hasConnection;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _hasConnection = false;
      _connectionStatusController.add(false);
      return false;
    }
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    
    // Only notify if status changed
    if (_hasConnection != hasConnection) {
      _hasConnection = hasConnection;
      _connectionStatusController.add(hasConnection);
      debugPrint('Connection status changed: $_hasConnection');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
}
