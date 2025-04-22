import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/shared/widgets/widgets.dart';

/// {@template auth_form}
/// A form for user authentication.
/// {@endtemplate}
class AuthForm extends StatefulWidget {
  /// {@macro auth_form}
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Navigate to home page or next screen
          // Navigator.of(context).pushReplacementNamed('/home');
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _WelcomeHeader(),
            const SizedBox(height: 32),
            _EmailInput(controller: _emailController),
            const SizedBox(height: 16),
            _PasswordInput(controller: _passwordController),
            const SizedBox(height: 32),
            const _LoginButton(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.account_circle_outlined,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Biftech',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Please sign in to continue',
          style: Theme.of(context).textTheme.bodyLarge,
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
          previous.status != current.status || previous.isValid != current.isValid,
      builder: (context, state) {
        return NeoButton(
          onTap: () {
            context.read<AuthCubit>().logInWithCredentials();
          },
          label: 'Login',
          isLoading: state.status.isInProgress,
          isEnabled: state.isValid,
        );
      },
    );
  }
}
