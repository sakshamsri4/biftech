import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/model/models.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/cred_button.dart';
import 'package:biftech/shared/widgets/cred_card.dart';
import 'package:biftech/shared/widgets/cred_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// {@template auth_form}
/// The login form with CRED design.
/// {@endtemplate}
class AuthFormRedesign extends StatefulWidget {
  /// {@macro auth_form}
  const AuthFormRedesign({
    required this.onSignUpTap,
    required this.onForgotPasswordTap,
    super.key,
  });

  /// Called when the user taps the sign up button.
  final VoidCallback onSignUpTap;

  /// Called when the user taps the forgot password button.
  final VoidCallback onForgotPasswordTap;

  @override
  State<AuthFormRedesign> createState() => _AuthFormRedesignState();
}

class _AuthFormRedesignState extends State<AuthFormRedesign>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _passwordController.dispose();
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
              content: Text(state.errorMessage ?? 'Authentication failed'),
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
                  if (!keyboardVisible) const _WelcomeHeader(),
                  if (!keyboardVisible) const SizedBox(height: 40),
                  CredCard(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _EmailInput(controller: _emailController),
                          const SizedBox(height: 20),
                          _PasswordInput(controller: _passwordController),
                          const SizedBox(height: 32),
                          const _LoginButton(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CredTextButton(
          onPressed: widget.onForgotPasswordTap,
          label: 'Forgot Password?',
          color: textWhite70,
        ),
        CredTextButton(
          onPressed: widget.onSignUpTap,
          label: 'Create Account',
          icon: Icons.arrow_forward_ios_rounded,
        ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Animated logo container
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x806C63FF), // accentPrimary with 50% opacity
                      Colors.transparent,
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
              // Inner circle with icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(
                      0x4D6C63FF,
                    ), // accentPrimary with 30% opacity
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color:
                          Color(0x4D6C63FF), // accentPrimary with 30% opacity
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: accentPrimary,
                  size: 36,
                ),
              ),
              // Animated ring
              _AnimatedRing(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8A84FF),
                Color(0xFF6C63FF),
              ],
            ).createShader(bounds);
          },
          child: Text(
            'Welcome Back',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: textWhite,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to continue to Biftech',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textWhite70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AnimatedRing extends StatefulWidget {
  @override
  _AnimatedRingState createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    const Color(0x336C63FF), // accentPrimary with 20% opacity
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: accentPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            0x806C63FF,
                          ), // accentPrimary with 50% opacity
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          hintText: 'Enter your password',
          obscureText: true,
          errorText: state.password.displayError != null
              ? state.password.error == PasswordValidationError.empty
                  ? 'Password cannot be empty'
                  : 'Password must be at least 6 characters'
              : null,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: textWhite50,
            size: 20,
          ),
          onChanged: (password) {
            context.read<AuthCubit>().passwordChanged(password);
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

class _LoginButton extends StatelessWidget {
  const _LoginButton();

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
          label: 'Sign In',
          icon: Icons.login_rounded,
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
