import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/view/auth_form.dart';
import 'package:biftech/features/auth/view/forgot_password_page.dart';
import 'package:biftech/features/auth/view/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template auth_page}
/// A page that allows users to log in, sign up, or reset their password.
/// {@endtemplate}
class AuthPage extends StatefulWidget {
  /// {@macro auth_page}
  const AuthPage({super.key});

  /// The route name for this page.
  static const routeName = '/login';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthCubit _authCubit;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: GestureDetector(
        // Dismiss keyboard when tapping outside of text fields
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          // Use resizeToAvoidBottomInset to handle keyboard appearance
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(_getTitle()),
            // Make the app bar responsive
            toolbarHeight: MediaQuery.of(context).size.height > 600 ? 56 : 48,
          ),
          body: SafeArea(
            // Use SafeArea to handle notches and system UI elements
            minimum: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Login';
      case 1:
        return 'Sign Up';
      case 2:
        return 'Forgot Password';
      default:
        return 'Authentication';
    }
  }

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0:
        return AuthForm(
          onSignUpTap: () => setState(() {
            _currentIndex = 1;
            _authCubit.changeMode(AuthMode.signUp);
          }),
          onForgotPasswordTap: () => setState(() {
            _currentIndex = 2;
            _authCubit.changeMode(AuthMode.forgotPassword);
          }),
        );
      case 1:
        return SignUpPage(
          onBackToLoginTap: () => setState(() {
            _currentIndex = 0;
            _authCubit.changeMode(AuthMode.login);
          }),
        );
      case 2:
        return ForgotPasswordPage(
          onBackToLoginTap: () => setState(() {
            _currentIndex = 0;
            _authCubit.changeMode(AuthMode.login);
          }),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
