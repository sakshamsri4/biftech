import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/repository/auth_repository.dart';
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
    _authRepository = AuthRepository(userBox: userBox);
  }

  /// Gets the authentication repository.
  static AuthRepository getAuthRepository() {
    if (_authRepository == null) {
      throw Exception('AuthService not initialized. Call initialize() first.');
    }
    return _authRepository!;
  }
}
