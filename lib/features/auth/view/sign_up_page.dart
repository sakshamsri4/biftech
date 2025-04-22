import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// {@template sign_up_page}
/// A page that allows users to sign up.
/// {@endtemplate}
class SignUpPage extends StatefulWidget {
  /// {@macro sign_up_page}
  const SignUpPage({
    required this.onBackToLoginTap,
    super.key,
  });

  /// Called when the user taps the back to login button.
  final VoidCallback onBackToLoginTap;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The auth mode is set by the parent widget
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Sign Up'),
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
                      content: Text(state.errorMessage ?? 'Sign Up Failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
              } else if (state.status.isSuccess) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                          Text(state.successMessage ?? 'Sign Up Successful'),
                      backgroundColor: Colors.green,
                    ),
                  );
                // Navigate to home page
                Future.delayed(Duration.zero, () {
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  }
                });
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
                    const _SignUpHeader(),
                    const SizedBox(height: 32),
                    _NameInput(controller: _nameController),
                    const SizedBox(height: 16),
                    _EmailInput(controller: _emailController),
                    const SizedBox(height: 16),
                    _PasswordInput(controller: _passwordController),
                    const SizedBox(height: 16),
                    _ConfirmedPasswordInput(
                      controller: _confirmedPasswordController,
                    ),
                    const SizedBox(height: 32),
                    const _SignUpButton(),
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

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Column(
      children: [
        Icon(
          Icons.person_add_outlined,
          size: isSmallScreen ? 60 : 80,
          color: Colors.blue,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Text(
          'Create an Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: isSmallScreen ? 20 : null,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          'Please fill in your details',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isSmallScreen ? 14 : null,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return NeoTextField(
          controller: controller,
          labelText: 'Full Name',
          errorText: state.name.displayError != null
              ? state.name.error == NameValidationError.empty
                  ? 'Name cannot be empty'
                  : 'Name must be at least 2 characters'
              : null,
          onChanged: (name) {
            context.read<AuthCubit>().nameChanged(name);
          },
        );
      },
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

class _ConfirmedPasswordInput extends StatelessWidget {
  const _ConfirmedPasswordInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return NeoTextField(
          controller: controller,
          labelText: 'Confirm Password',
          obscureText: true,
          errorText: state.confirmedPassword.displayError != null
              ? state.confirmedPassword.error ==
                      ConfirmedPasswordValidationError.empty
                  ? 'Please confirm your password'
                  : 'Passwords do not match'
              : null,
          onChanged: (confirmedPassword) {
            context
                .read<AuthCubit>()
                .confirmedPasswordChanged(confirmedPassword);
          },
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

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
          label: 'Sign Up',
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
      child: const Text('Already have an account? Login'),
    );
  }
}
