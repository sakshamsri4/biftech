import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:biftech/features/auth/model/models.dart';

/// {@template auth_state}
/// Represents the state of the authentication form.
/// {@endtemplate}
class AuthState extends Equatable {
  /// {@macro auth_state}
  const AuthState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  /// The current email input.
  final Email email;

  /// The current password input.
  final Password password;

  /// The form submission status.
  final FormzSubmissionStatus status;

  /// Whether the form is valid.
  final bool isValid;

  /// The error message if authentication fails.
  final String? errorMessage;

  /// Creates a copy of this [AuthState] with the given values.
  AuthState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, status, isValid, errorMessage];
}
