import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/repository/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// {@template auth_service}
/// Service for initializing and providing authentication-related dependencies.
/// {@endtemplate}
class AuthService {
  /// Private constructor to prevent instantiation.
  AuthService._();

  static AuthRepository? _authRepository;

  /// Initializes the authentication service.
  static Future<void> initialize() async {
    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());

    // Open boxes
    final userBox = await Hive.openBox<UserModel>('users');

    // Create repository
    _authRepository = AuthRepository.standard(userBox);
  }

  /// Initializes the authentication service with a fallback mechanism
  /// when the primary initialization fails.
  ///
  /// This creates an in-memory repository that doesn't persist data
  /// but allows the app to function without crashing.
  static Future<void> initializeWithFallback() async {
    try {
      // Try to register adapter if not already registered
      if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      // Create an in-memory box that doesn't persist to disk
      final userBox = await Hive.openBox<UserModel>(
        'users_memory',
        path: ':memory:',
      );

      // Create repository with the in-memory box
      _authRepository = AuthRepository.standard(userBox);
    } catch (e) {
      // Last resort fallback - create a minimal working repository
      _authRepository = AuthRepository.fallback();
    }
  }

  /// Gets the authentication repository.
  static AuthRepository getAuthRepository() {
    if (_authRepository == null) {
      throw Exception('AuthService not initialized. Call initialize() first.');
    }
    return _authRepository!;
  }

  /// Overrides the repository for testing purposes.
  /// This should only be used in tests.
  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void overrideRepositoryForTesting(AuthRepository repository) {
    _authRepository = repository;
  }
}
