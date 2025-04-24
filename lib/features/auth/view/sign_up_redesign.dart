import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/cred_button.dart';
import 'package:biftech/shared/widgets/cred_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// {@template sign_up_page}
/// The sign up page with CRED design.
/// {@endtemplate}
class SignUpRedesign extends StatefulWidget {
  /// {@macro sign_up_page}
  const SignUpRedesign({
    required this.onBackToLoginTap,
    super.key,
  });

  /// Called when the user taps the back to login button.
  final VoidCallback onBackToLoginTap;

  @override
  State<SignUpRedesign> createState() => _SignUpRedesignState();
}

class _SignUpRedesignState extends State<SignUpRedesign>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == FormzSubmissionStatus.failure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed'),
              backgroundColor: error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenSize.height -
                MediaQuery.of(context).viewInsets.bottom -
                100,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: keyboardVisible
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!keyboardVisible) const _CreateAccountHeader(),
                  if (!keyboardVisible) const SizedBox(height: 40),
                  _NameInput(controller: _nameController),
                  const SizedBox(height: 20),
                  _EmailInput(controller: _emailController),
                  const SizedBox(height: 20),
                  _PasswordInput(controller: _passwordController),
                  const SizedBox(height: 20),
                  _ConfirmPasswordInput(controller: _confirmPasswordController),
                  const SizedBox(height: 32),
                  const _SignUpButton(),
                  const SizedBox(height: 24),
                  Center(
                    child: CredTextButton(
                      onPressed: widget.onBackToLoginTap,
                      label: 'Already have an account? Sign In',
                      color: textWhite70,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAccountHeader extends StatelessWidget {
  const _CreateAccountHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: secondaryBackground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentPrimary.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_outlined,
            color: accentPrimary,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: textWhite,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Sign up to get started with Biftech',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textWhite70,
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
        return CredTextField(
          controller: controller,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          errorText: state.name.displayError != null
              ? state.name.error == NameValidationError.empty
                  ? 'Name cannot be empty'
                  : 'Name must be at least 2 characters'
              : null,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: textWhite50,
            size: 20,
          ),
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
        return CredTextField(
          controller: controller,
          labelText: 'Email Address',
          hintText: 'Enter your email',
          errorText: state.email.displayError != null
              ? state.email.error == EmailValidationError.empty
                  ? 'Email cannot be empty'
                  : 'Invalid email format'
              : null,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: textWhite50,
            size: 20,
          ),
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
        return CredTextField(
          controller: controller,
          labelText: 'Password',
          hintText: 'Create a password',
          obscureText: true,
          errorText: state.password.displayError != null
              ? state.password.error == PasswordValidationError.empty
                  ? 'Password cannot be empty'
                  : 'Password must be at least 6 characters'
              : null,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: textWhite50,
            size: 20,
          ),
          onChanged: (password) {
            context.read<AuthCubit>().passwordChanged(password);
          },
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  const _ConfirmPasswordInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return CredTextField(
          controller: controller,
          labelText: 'Confirm Password',
          hintText: 'Confirm your password',
          obscureText: true,
          errorText: state.confirmedPassword.displayError != null
              ? state.confirmedPassword.error ==
                      ConfirmedPasswordValidationError.empty
                  ? 'Please confirm your password'
                  : 'Passwords do not match'
              : null,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: textWhite50,
            size: 20,
          ),
          onChanged: (confirmedPassword) {
            context
                .read<AuthCubit>()
                .confirmedPasswordChanged(confirmedPassword);
          },
          onSubmitted: (_) {
            if (context.read<AuthCubit>().state.isValid) {
              context.read<AuthCubit>().submitForm();
            }
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
        return CredButton(
          onPressed: state.isValid
              ? () {
                  HapticFeedback.mediumImpact();
                  context.read<AuthCubit>().submitForm();
                }
              : null,
          label: 'Create Account',
          icon: Icons.person_add_alt_1_rounded,
          isLoading: state.status.isInProgress,
          isEnabled: state.isValid,
          gradient: const LinearGradient(
            colors: [Color(0xFF8A84FF), Color(0xFF6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      },
    );
  }
}
