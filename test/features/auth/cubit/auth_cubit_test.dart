import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/repository/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    // Set up mock responses
    when(
      () => mockAuthRepository.loginUser(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).thenAnswer(
      (_) async => UserModel(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
      ),
    );

    when(
      () => mockAuthRepository.loginUser(
        email: 'wrong@example.com',
        password: 'wrongpassword',
      ),
    ).thenAnswer((_) async => null);

    when(() => mockAuthRepository.userExists('new@example.com'))
        .thenReturn(false);

    when(
      () => mockAuthRepository.registerUser(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockAuthRepository.resetPassword('test@example.com'))
        .thenAnswer((_) async => true);
  });

  group('AuthCubit', () {
    test('initial state is correct', () {
      final authCubit = AuthCubit(authRepository: mockAuthRepository);
      expect(authCubit.state, const AuthState());
    });

    group('emailChanged', () {
      blocTest<AuthCubit, AuthState>(
        'emits updated email and validity when email changes',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.emailChanged('test@example.com'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.email.value, 'email value', 'test@example.com')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when email is empty',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.emailChanged(''),
        expect: () => [
          isA<AuthState>()
              .having(
                (s) => s.email.error,
                'email error',
                EmailValidationError.empty,
              )
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when email format is invalid',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.emailChanged('invalid-email'),
        expect: () => [
          isA<AuthState>()
              .having(
                (s) => s.email.error,
                'email error',
                EmailValidationError.invalid,
              )
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<AuthCubit, AuthState>(
        'emits updated password and validity when password changes',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.passwordChanged('password123'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.password.value, 'password value', 'password123')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when password is empty',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.passwordChanged(''),
        expect: () => [
          isA<AuthState>()
              .having(
                (s) => s.password.error,
                'password error',
                PasswordValidationError.empty,
              )
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits invalid state when password is too short',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.passwordChanged('12345'),
        expect: () => [
          isA<AuthState>()
              .having(
                (s) => s.password.error,
                'password error',
                PasswordValidationError.tooShort,
              )
              .having((s) => s.isValid, 'isValid', false),
        ],
      );
    });

    group('submitForm', () {
      blocTest<AuthCubit, AuthState>(
        'does nothing when form is invalid',
        build: () => AuthCubit(authRepository: mockAuthRepository),
        act: (cubit) => cubit.submitForm(),
        expect: () => <AuthState>[],
      );

      group('login mode', () {
        blocTest<AuthCubit, AuthState>(
          'emits loading and success when credentials are valid',
          build: () => AuthCubit(authRepository: mockAuthRepository),
          seed: () => const AuthState(
            email: Email.dirty('test@example.com'),
            password: Password.dirty('password123'),
            isValid: true,
          ),
          act: (cubit) => cubit.submitForm(),
          wait: const Duration(seconds: 2),
          expect: () => [
            isA<AuthState>().having(
              (s) => s.status,
              'status',
              FormzSubmissionStatus.inProgress,
            ),
            isA<AuthState>()
                .having(
                  (s) => s.status,
                  'status',
                  FormzSubmissionStatus.success,
                )
                .having(
                  (s) => s.successMessage,
                  'successMessage',
                  'Login successful',
                ),
          ],
        );

        blocTest<AuthCubit, AuthState>(
          'emits loading and failure when credentials are invalid',
          build: () => AuthCubit(authRepository: mockAuthRepository),
          seed: () => const AuthState(
            email: Email.dirty('wrong@example.com'),
            password: Password.dirty('wrongpassword'),
            isValid: true,
          ),
          act: (cubit) => cubit.submitForm(),
          wait: const Duration(seconds: 2),
          expect: () => [
            isA<AuthState>().having(
              (s) => s.status,
              'status',
              FormzSubmissionStatus.inProgress,
            ),
            isA<AuthState>()
                .having(
                  (s) => s.status,
                  'status',
                  FormzSubmissionStatus.failure,
                )
                .having(
                  (s) => s.errorMessage,
                  'errorMessage',
                  'Invalid credentials',
                ),
          ],
        );
      });

      group('sign up mode', () {
        blocTest<AuthCubit, AuthState>(
          'emits loading and success when form is valid',
          build: () => AuthCubit(authRepository: mockAuthRepository),
          seed: () => const AuthState(
            mode: AuthMode.signUp,
            name: Name.dirty('Test User'),
            email: Email.dirty('new@example.com'),
            password: Password.dirty('password123'),
            confirmedPassword: ConfirmedPassword.dirty(
              password: 'password123',
              value: 'password123',
            ),
            isValid: true,
          ),
          act: (cubit) => cubit.submitForm(),
          wait: const Duration(seconds: 2),
          expect: () => [
            isA<AuthState>().having(
              (s) => s.status,
              'status',
              FormzSubmissionStatus.inProgress,
            ),
            isA<AuthState>()
                .having(
                  (s) => s.status,
                  'status',
                  FormzSubmissionStatus.success,
                )
                .having(
                  (s) => s.successMessage,
                  'successMessage',
                  'Account created successfully',
                ),
          ],
        );
      });

      group('forgot password mode', () {
        blocTest<AuthCubit, AuthState>(
          'emits loading and success when email is valid',
          build: () => AuthCubit(authRepository: mockAuthRepository),
          seed: () => const AuthState(
            mode: AuthMode.forgotPassword,
            email: Email.dirty('test@example.com'),
            isValid: true,
          ),
          act: (cubit) => cubit.submitForm(),
          wait: const Duration(seconds: 2),
          expect: () => [
            isA<AuthState>().having(
              (s) => s.status,
              'status',
              FormzSubmissionStatus.inProgress,
            ),
            isA<AuthState>()
                .having(
                  (s) => s.status,
                  'status',
                  FormzSubmissionStatus.success,
                )
                .having(
                  (s) => s.successMessage,
                  'successMessage',
                  'Password reset instructions sent to test@example.com',
                ),
          ],
        );
      });
    });
  });
}
