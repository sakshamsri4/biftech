import 'package:formz/formz.dart';

/// Validation errors for the confirmed password field.
enum ConfirmedPasswordValidationError {
  /// Confirmed password is empty.
  empty,

  /// Confirmed password does not match the original password.
  mismatch,
}

/// {@template confirmed_password}
/// Form input for a confirmed password field.
/// {@endtemplate}
class ConfirmedPassword
    extends FormzInput<String, ConfirmedPasswordValidationError> {
  /// {@macro confirmed_password}
  const ConfirmedPassword.pure({this.password = ''}) : super.pure('');

  /// {@macro confirmed_password}
  const ConfirmedPassword.dirty({required this.password, String value = ''})
      : super.dirty(value);

  /// The original password to compare against.
  final String password;

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (value.isEmpty) return ConfirmedPasswordValidationError.empty;
    if (value != password) return ConfirmedPasswordValidationError.mismatch;
    return null;
  }
}
