import 'package:biftech/features/auth/model/user_model.dart';
import 'package:hive/hive.dart';

/// {@template auth_repository}
/// Repository for authentication-related operations.
/// {@endtemplate}
class AuthRepository {
  /// {@macro auth_repository}
  AuthRepository({
    required Box<UserModel> userBox,
  }) : _userBox = userBox;

  final Box<UserModel> _userBox;

  /// The key for the current user in the Hive box.
  static const String currentUserKey = 'current_user';

  /// The key for the users collection in the Hive box.
  static const String usersKey = 'users';

  /// Registers a new user.
  Future<void> registerUser({
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
  }

  /// Logs in a user with the given credentials.
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
      await _userBox.put(currentUserKey, currentUser);
      return user;
    }

    return null;
  }

  /// Logs out the current user.
  Future<void> logoutUser() async {
    await _userBox.delete(currentUserKey);
  }

  /// Gets the current logged-in user.
  UserModel? getCurrentUser() {
    return _userBox.get(currentUserKey);
  }

  /// Checks if a user is currently logged in.
  bool isLoggedIn() {
    return _userBox.containsKey(currentUserKey);
  }

  /// Checks if a user with the given email exists.
  bool userExists(String email) {
    return _userBox.containsKey(email);
  }

  /// Resets the password for a user with the given email.
  ///
  /// In a real app, this would send a password reset email.
  /// For this demo, we'll just simulate the process.
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
