import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/features/auth/repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';

/// {@template auth_cubit}
/// Manages the authentication state of the application.
/// {@endtemplate}
class AuthCubit extends Cubit<AuthState> {
  /// {@macro auth_cubit}
  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState());

  final AuthRepository _authRepository;

  /// Changes the authentication mode.
  void changeMode(AuthMode mode) {
    emit(
      state.copyWith(
        mode: mode,
        status: FormzSubmissionStatus.initial,
      ),
    );
    _validateForm();
  }

  /// Updates the name field (for sign up).
  void nameChanged(String value) {
    final name = Name.dirty(value);
    emit(state.copyWith(name: name));
    _validateForm();
  }

  /// Updates the email field.
  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(email: email));
    _validateForm();
  }

  /// Updates the password field.
  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(password: password));

    // If we're in sign up mode, also validate the confirmed password
    if (state.mode == AuthMode.signUp) {
      final confirmedPassword = ConfirmedPassword.dirty(
        password: value,
        value: state.confirmedPassword.value,
      );
      emit(state.copyWith(confirmedPassword: confirmedPassword));
    }

    _validateForm();
  }

  /// Updates the confirmed password field (for sign up).
  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: value,
    );
    emit(state.copyWith(confirmedPassword: confirmedPassword));
    _validateForm();
  }

  /// Validates the form based on the current mode.
  void _validateForm() {
    bool isValid;

    switch (state.mode) {
      case AuthMode.login:
        isValid = Formz.validate([state.email, state.password]);
      case AuthMode.signUp:
        isValid = Formz.validate([
          state.name,
          state.email,
          state.password,
          state.confirmedPassword,
        ]);
      case AuthMode.forgotPassword:
        isValid = Formz.validate([state.email]);
    }

    emit(state.copyWith(isValid: isValid));
  }

  /// Submits the authentication form based on the current mode.
  Future<void> submitForm() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(seconds: 1));

      switch (state.mode) {
        case AuthMode.login:
          await _logIn();
        case AuthMode.signUp:
          await _signUp();
        case AuthMode.forgotPassword:
          await _forgotPassword();
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Handles the login process.
  Future<void> _logIn() async {
    try {
      final user = await _authRepository.loginUser(
        email: state.email.value,
        password: state.password.value,
      );

      if (user != null) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            successMessage: 'Login successful',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Invalid credentials',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Login failed: $e',
        ),
      );
    }
  }

  /// Handles the sign up process.
  Future<void> _signUp() async {
    try {
      // Check if user already exists
      if (_authRepository.userExists(state.email.value)) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Email already registered',
          ),
        );
        return;
      }

      // Register the new user
      await _authRepository.registerUser(
        name: state.name.value,
        email: state.email.value,
        password: state.password.value,
      );

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: 'Account created successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Registration failed: $e',
        ),
      );
    }
  }

  /// Handles the forgot password process.
  Future<void> _forgotPassword() async {
    try {
      final success = await _authRepository.resetPassword(state.email.value);

      if (success) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            successMessage:
                'Password reset instructions sent to ${state.email.value}',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Email not found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Password reset failed: $e',
        ),
      );
    }
  }
}
