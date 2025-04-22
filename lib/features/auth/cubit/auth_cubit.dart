import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';

/// {@template auth_cubit}
/// Manages the authentication state of the application.
/// {@endtemplate}
class AuthCubit extends Cubit<AuthState> {
  /// {@macro auth_cubit}
  AuthCubit() : super(const AuthState());

  /// Updates the email field.
  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  /// Updates the password field.
  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  /// Submits the login form.
  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;
    
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // For demo purposes, we'll accept any valid form
      // In a real app, this would call an authentication service
      if (state.email.value == 'test@example.com' && 
          state.password.value == 'password123') {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
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
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
