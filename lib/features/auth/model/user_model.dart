import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// {@template user_model}
/// Model for a user in the application.
/// {@endtemplate}
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  /// {@macro user_model}
  /// Creates a user with the given name, email, and password.
  /// The password is automatically hashed before storage.
  UserModel({
    required this.name,
    required this.email,
    required String password,
  }) : passwordHash = _hashPassword(password);

  /// Creates a user with a pre-computed password hash.
  /// This constructor should only be used when deserializing from storage.
  UserModel.withHash({
    required this.name,
    required this.email,
    required this.passwordHash,
  });

  /// The name of the user.
  @HiveField(0)
  final String name;

  /// The email of the user.
  @HiveField(1)
  final String email;

  /// The hashed password of the user.
  /// Never store plain-text passwords.
  @HiveField(2)
  final String passwordHash;

  /// Validates if the provided password matches the stored hash.
  bool validatePassword(String password) {
    final hashedInput = _hashPassword(password);
    return hashedInput == passwordHash;
  }

  /// Creates a copy of this [UserModel] with the given values.
  UserModel copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? '', // If no new password, we'll keep the old hash
    );
  }

  /// Hashes a password using SHA-256.
  /// In a production app, use a more secure algorithm like bcrypt or Argon2.
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  String toString() => 'UserModel(name: $name, email: $email)';
}
