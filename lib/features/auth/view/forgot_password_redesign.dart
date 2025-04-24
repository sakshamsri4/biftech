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

/// {@template forgot_password_page}
/// The forgot password page with CRED design.
/// {@endtemplate}
class ForgotPasswordRedesign extends StatefulWidget {
  /// {@macro forgot_password_page}
  const ForgotPasswordRedesign({
    required this.onBackToLoginTap,
    super.key,
  });

  /// Called when the user taps the back to login button.
  final VoidCallback onBackToLoginTap;

  @override
  State<ForgotPasswordRedesign> createState() => _ForgotPasswordRedesignState();
}

class _ForgotPasswordRedesignState extends State<ForgotPasswordRedesign>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
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
    _emailController.dispose();
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
              content: Text(state.errorMessage ?? 'Password reset failed'),
              backgroundColor: error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state.status == FormzSubmissionStatus.success) {
          // Show success message and navigate back to login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage ?? 'Password reset email sent',
              ),
              backgroundColor: success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          // Navigate back to login after a short delay
          Future.delayed(const Duration(seconds: 2), widget.onBackToLoginTap);
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
                  if (!keyboardVisible) const _ResetPasswordHeader(),
                  if (!keyboardVisible) const SizedBox(height: 40),
                  _EmailInput(controller: _emailController),
                  const SizedBox(height: 32),
                  const _ResetPasswordButton(),
                  const SizedBox(height: 24),
                  Center(
                    child: CredTextButton(
                      onPressed: widget.onBackToLoginTap,
                      label: 'Back to Login',
                      icon: Icons.arrow_back_ios_rounded,
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

class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

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
                color: accentPrimary.withAlpha(51), // 0.2 opacity
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: accentPrimary,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Reset Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: textWhite,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email to receive a password reset link',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textWhite70,
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
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: textWhite50,
            size: 20,
          ),
          onChanged: (email) {
            context.read<AuthCubit>().emailChanged(email);
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

class _ResetPasswordButton extends StatelessWidget {
  const _ResetPasswordButton();

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
          label: 'Reset Password',
          icon: Icons.send_rounded,
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
