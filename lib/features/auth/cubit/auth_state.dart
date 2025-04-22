import 'package:biftech/features/auth/model/models.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

/// The different authentication modes available.
enum AuthMode {
  /// Login mode for existing users.
  login,

  /// Sign up mode for new users.
  signUp,

  /// Forgot password mode for password recovery.
  forgotPassword,
}

/// {@template auth_state}
/// Represents the state of the authentication form.
/// {@endtemplate}
class AuthState extends Equatable {
  /// {@macro auth_state}
  const AuthState({
    this.mode = AuthMode.login,
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.successMessage,
  });

  /// The current authentication mode.
  final AuthMode mode;

  /// The current name input (for sign up).
  final Name name;

  /// The current email input.
  final Email email;

  /// The current password input.
  final Password password;

  /// The current confirmed password input (for sign up).
  final ConfirmedPassword confirmedPassword;

  /// The form submission status.
  final FormzSubmissionStatus status;

  /// Whether the form is valid.
  final bool isValid;

  /// The error message if authentication fails.
  final String? errorMessage;

  /// The success message if authentication succeeds.
  final String? successMessage;

  /// Creates a copy of this [AuthState] with the given values.
  AuthState copyWith({
    AuthMode? mode,
    Name? name,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        name,
        email,
        password,
        confirmedPassword,
        status,
        isValid,
        errorMessage,
        successMessage,
      ];
}
