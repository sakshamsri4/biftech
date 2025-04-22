import 'package:biftech/features/auth/model/user_model.dart';
import 'package:hive/hive.dart';

/// {@template auth_repository}
/// Repository for authentication-related operations.
/// {@endtemplate}
abstract class AuthRepository {
  /// Creates a standard repository implementation using Hive storage.
  factory AuthRepository.standard(Box<UserModel> userBox) {
    return HiveAuthRepository(userBox: userBox);
  }

  /// Creates a fallback repository that works without persistent storage.
  factory AuthRepository.fallback() {
    return InMemoryAuthRepository();
  }

  /// The key for the current user in the Hive box.
  static const String currentUserKey = 'current_user';

  /// Registers a new user and sets them as the current user.
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  });

  /// Logs in a user with the given credentials.
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  });

  /// Logs out the current user.
  Future<void> logoutUser();

  /// Gets the current logged-in user.
  UserModel? getCurrentUser();

  /// Checks if a user is currently logged in.
  bool isLoggedIn();

  /// Checks if a user with the given email exists.
  bool userExists(String email);

  /// Resets the password for a user with the given email.
  Future<bool> resetPassword(String email);
}

/// {@template hive_auth_repository}
/// Implementation of AuthRepository that uses Hive for storage.
/// {@endtemplate}
class HiveAuthRepository implements AuthRepository {
  /// {@macro hive_auth_repository}
  HiveAuthRepository({required Box<UserModel> userBox}) : _userBox = userBox;

  final Box<UserModel> _userBox;

  @override
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = UserModel(
      name: name,
      email: email,
      password: password,
    );

    // Store the user with email as key
    await _userBox.put(email, user);

    // Create a copy for the current user to avoid Hive error
    final currentUser = UserModel(
      name: name,
      email: email,
      password: password,
    );

    // Set as current user
    await _userBox.put(AuthRepository.currentUserKey, currentUser);

    return user;
  }

  @override
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final user = _userBox.get(email);

    if (user != null && user.password == password) {
      // Create a copy of the user to avoid the HiveError:
      // "The same instance of an HiveObject cannot be stored
      // with two different keys"
      final currentUser = UserModel(
        name: user.name,
        email: user.email,
        password: user.password,
      );

      // Store the current user copy
      await _userBox.put(AuthRepository.currentUserKey, currentUser);
      return user;
    }

    return null;
  }

  @override
  Future<void> logoutUser() async {
    await _userBox.delete(AuthRepository.currentUserKey);
  }

  @override
  UserModel? getCurrentUser() {
    return _userBox.get(AuthRepository.currentUserKey);
  }

  @override
  bool isLoggedIn() {
    return _userBox.containsKey(AuthRepository.currentUserKey);
  }

  @override
  bool userExists(String email) {
    return _userBox.containsKey(email);
  }

  @override
  Future<bool> resetPassword(String email) async {
    final user = _userBox.get(email);

    if (user != null) {
      // In a real app, we would send a password reset email
      // For this demo, we'll just return true to indicate success
      return true;
    }

    return false;
  }
}

/// {@template in_memory_auth_repository}
/// Implementation of AuthRepository that uses in-memory storage.
/// Used as a fallback when Hive initialization fails.
/// {@endtemplate}
class InMemoryAuthRepository implements AuthRepository {
  /// {@macro in_memory_auth_repository}
  InMemoryAuthRepository();

  UserModel? _currentUser;
  final Map<String, UserModel> _users = {};

  @override
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = UserModel(
      name: name,
      email: email,
      password: password,
    );

    _users[email] = user;
    _currentUser = user;

    return user;
  }

  @override
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final user = _users[email];

    if (user != null && user.password == password) {
      _currentUser = user;
      return user;
    }

    return null;
  }

  @override
  Future<void> logoutUser() async {
    _currentUser = null;
  }

  @override
  UserModel? getCurrentUser() {
    return _currentUser;
  }

  @override
  bool isLoggedIn() {
    return _currentUser != null;
  }

  @override
  bool userExists(String email) {
    return _users.containsKey(email);
  }

  @override
  Future<bool> resetPassword(String email) async {
    return _users.containsKey(email);
  }
}
