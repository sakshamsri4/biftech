import 'package:equatable/equatable.dart';

/// {@template auth_model}
/// Model for authentication data.
/// {@endtemplate}
class AuthModel extends Equatable {
  /// {@macro auth_model}
  const AuthModel({
    required this.email,
    required this.password,
  });

  /// The user's email.
  final String email;

  /// The user's password.
  final String password;

  /// Creates a copy of this [AuthModel] with the given values.
  AuthModel copyWith({
    String? email,
    String? password,
  }) {
    return AuthModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [email, password];
}
