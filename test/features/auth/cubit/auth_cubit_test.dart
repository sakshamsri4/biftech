import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';

void main() {
  group('AuthCubit', () {
    test('initial state is correct', () {
      final authCubit = AuthCubit();
      expect(authCubit.state, const AuthState());
    });

    group('emailChanged', () {
      blocTest<AuthCubit, AuthState>(
        'emits updated email and validity when email changes',
        build: () => AuthCubit(),
        act: (cubit) => cubit.emailChanged('test@example.com'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.email.value, 'email value', 'test@example.com')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when email is empty',
        build: () => AuthCubit(),
        act: (cubit) => cubit.emailChanged(''),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.email.error, 'email error', EmailValidationError.empty)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when email format is invalid',
        build: () => AuthCubit(),
        act: (cubit) => cubit.emailChanged('invalid-email'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.email.error, 'email error', EmailValidationError.invalid)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<AuthCubit, AuthState>(
        'emits updated password and validity when password changes',
        build: () => AuthCubit(),
        act: (cubit) => cubit.passwordChanged('password123'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.password.value, 'password value', 'password123')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when password is empty',
        build: () => AuthCubit(),
        act: (cubit) => cubit.passwordChanged(''),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.password.error, 'password error', PasswordValidationError.empty)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when password is too short',
        build: () => AuthCubit(),
        act: (cubit) => cubit.passwordChanged('12345'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.password.error, 'password error', PasswordValidationError.tooShort)
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('logInWithCredentials', () {
      blocTest<AuthCubit, AuthState>(
        'does nothing when form is invalid',
        build: () => AuthCubit(),
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => [],
      );

      blocTest<AuthCubit, AuthState>(
        'emits loading and success when credentials are valid',
        build: () => AuthCubit(),
        seed: () => AuthState(
          email: const Email.dirty('test@example.com'),
          password: const Password.dirty('password123'),
          isValid: true,
        ),
        act: (cubit) => cubit.logInWithCredentials(),
        wait: const Duration(seconds: 2),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
          isA<AuthState>()
              .having((s) => s.status, 'status', FormzSubmissionStatus.success),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits loading and failure when credentials are invalid',
        build: () => AuthCubit(),
        seed: () => AuthState(
          email: const Email.dirty('wrong@example.com'),
          password: const Password.dirty('wrongpassword'),
          isValid: true,
        ),
        act: (cubit) => cubit.logInWithCredentials(),
        wait: const Duration(seconds: 2),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
          isA<AuthState>()
              .having((s) => s.status, 'status', FormzSubmissionStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', 'Invalid credentials'),
        ],
      );
    });
  });
}
