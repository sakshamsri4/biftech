import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// {@template auth_form}
/// A form for user authentication.
/// {@endtemplate}
class AuthForm extends StatefulWidget {
  /// {@macro auth_form}
  const AuthForm({
    required this.onSignUpTap,
    required this.onForgotPasswordTap,
    super.key,
  });

  /// Called when the user taps the sign up button.
  final VoidCallback onSignUpTap;

  /// Called when the user taps the forgot password button.
  final VoidCallback onForgotPasswordTap;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the auth mode to login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().changeMode(AuthMode.login);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size to make the UI responsive
    final screenSize = MediaQuery.of(context).size;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure'),
                backgroundColor: Colors.red,
              ),
            );
        } else if (state.status.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Login Successful'),
                backgroundColor: Colors.green,
              ),
            );
          // Navigate to home page
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (_) => false,
          );
        }
      },
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            // Add extra bottom padding when keyboard is visible
            vertical: keyboardVisible ? 20 : 0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  100,
            ),
            child: Column(
              mainAxisAlignment: keyboardVisible
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                if (!keyboardVisible) const _WelcomeHeader(),
                if (!keyboardVisible) const SizedBox(height: 32),
                _EmailInput(controller: _emailController),
                const SizedBox(height: 16),
                _PasswordInput(controller: _passwordController),
                const SizedBox(height: 32),
                const _LoginButton(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ForgotPasswordButton(
                      onPressed: widget.onForgotPasswordTap,
                    ),
                    _SignUpButton(
                      onPressed: widget.onSignUpTap,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    // Make the header responsive based on screen size
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Column(
      children: [
        Icon(
          Icons.account_circle_outlined,
          // Adjust icon size based on screen size
          size: isSmallScreen ? 60 : 80,
          color: Colors.blue,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Text(
          'Welcome to Biftech',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                // Adjust font size based on screen size
                fontSize: isSmallScreen ? 20 : null,
              ),
          // Center text and ensure it doesn't overflow
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          'Please sign in to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Adjust font size based on screen size
                fontSize: isSmallScreen ? 14 : null,
              ),
          // Center text and ensure it doesn't overflow
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return NeoTextField(
          controller: controller,
          labelText: 'Email',
          errorText: state.email.displayError != null
              ? state.email.error == EmailValidationError.empty
                  ? 'Email cannot be empty'
                  : 'Invalid email format'
              : null,
          onChanged: (email) {
            context.read<AuthCubit>().emailChanged(email);
          },
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return NeoTextField(
          controller: controller,
          labelText: 'Password',
          obscureText: true,
          errorText: state.password.displayError != null
              ? state.password.error == PasswordValidationError.empty
                  ? 'Password cannot be empty'
                  : 'Password must be at least 6 characters'
              : null,
          onChanged: (password) {
            context.read<AuthCubit>().passwordChanged(password);
          },
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return NeoButton(
          onTap: () {
            context.read<AuthCubit>().submitForm();
          },
          label: 'Login',
          isLoading: state.status.isInProgress,
          isEnabled: state.isValid,
        );
      },
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text('Forgot Password?'),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text('Sign Up'),
    );
  }
}
