import 'package:formz/formz.dart';

/// Validation errors for the name field.
enum NameValidationError {
  /// Name is empty.
  empty,

  /// Name is too short.
  tooShort,
}

/// {@template name}
/// Form input for a name field.
/// {@endtemplate}
class Name extends FormzInput<String, NameValidationError> {
  /// {@macro name}
  const Name.pure() : super.pure('');

  /// {@macro name}
  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    if (value.isEmpty) return NameValidationError.empty;
    if (value.length < 2) return NameValidationError.tooShort;
    return null;
  }
}
