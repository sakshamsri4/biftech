import 'package:formz/formz.dart';

/// Validation errors for the password field.
enum PasswordValidationError {
  /// Password is empty.
  empty,

  /// Password is too short.
  tooShort,
}

/// {@template password}
/// Form input for a password field.
/// {@endtemplate}
class Password extends FormzInput<String, PasswordValidationError> {
  /// {@macro password}
  const Password.pure() : super.pure('');

  /// {@macro password}
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 6) return PasswordValidationError.tooShort;
    return null;
  }
}
