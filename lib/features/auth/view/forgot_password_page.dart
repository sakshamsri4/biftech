import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// {@template forgot_password_page}
/// A page that allows users to reset their password.
/// {@endtemplate}
class ForgotPasswordPage extends StatefulWidget {
  /// {@macro forgot_password_page}
  const ForgotPasswordPage({
    required this.onBackToLoginTap,
    super.key,
  });

  /// Called when the user taps the back to login button.
  final VoidCallback onBackToLoginTap;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The auth mode is set by the parent widget
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Forgot Password'),
          toolbarHeight: MediaQuery.of(context).size.height > 600 ? 56 : 48,
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocListener<AuthCubit, AuthState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status.isFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                          Text(state.errorMessage ?? 'Password Reset Failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
              } else if (state.status.isSuccess) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.successMessage ?? 'Password Reset Email Sent',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                // Navigate back to login page
                Navigator.of(context).pop();
              }
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const _ForgotPasswordHeader(),
                    const SizedBox(height: 32),
                    _EmailInput(controller: _emailController),
                    const SizedBox(height: 32),
                    const _SubmitButton(),
                    const SizedBox(height: 16),
                    _BackToLoginButton(
                      onPressed: widget.onBackToLoginTap,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
  const _ForgotPasswordHeader();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Column(
      children: [
        Icon(
          Icons.lock_reset_outlined,
          size: isSmallScreen ? 60 : 80,
          color: Colors.blue,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Text(
          'Forgot Password',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: isSmallScreen ? 20 : null,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          'Enter your email to reset your password',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isSmallScreen ? 14 : null,
              ),
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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

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
          label: 'Reset Password',
          isLoading: state.status.isInProgress,
          isEnabled: state.isValid,
        );
      },
    );
  }
}

class _BackToLoginButton extends StatelessWidget {
  const _BackToLoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text('Back to Login'),
    );
  }
}
