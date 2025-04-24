import 'dart:ui';

import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/cubit/auth_state.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:biftech/features/auth/view/auth_form_redesign.dart';
import 'package:biftech/features/auth/view/forgot_password_redesign.dart';
import 'package:biftech/features/auth/view/sign_up_redesign.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

/// {@template auth_page}
/// The main authentication page that manages different auth modes.
/// {@endtemplate}
class AuthPageRedesign extends StatefulWidget {
  /// {@macro auth_page}
  const AuthPageRedesign({super.key});

  @override
  State<AuthPageRedesign> createState() => _AuthPageRedesignState();
}

class _AuthPageRedesignState extends State<AuthPageRedesign>
    with SingleTickerProviderStateMixin {
  late final AuthCubit _authCubit;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    try {
      _authCubit = AuthCubit(
        authRepository: AuthService.getAuthRepository(),
      );
    } catch (e) {
      debugPrint('Error initializing AuthCubit: $e');
      // Create a fallback repository that doesn't persist data
      _authCubit = AuthCubit(
        authRepository: AuthService.createInMemoryRepository(),
      );
    }
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    _authCubit.close();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      switch (_tabController.index) {
        case 0:
          _authCubit.changeMode(AuthMode.login);
        case 1:
          _authCubit.changeMode(AuthMode.signUp);
        case 2:
          _authCubit.changeMode(AuthMode.forgotPassword);
      }
    }
  }

  void _changeTab(int index) {
    HapticFeedback.selectionClick();
    _tabController.animateTo(index);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == FormzSubmissionStatus.success,
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.success) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Success'),
                backgroundColor: success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );

            // Navigate to home page
            if (state.mode == AuthMode.login || state.mode == AuthMode.signUp) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (_) => false,
              );
            }
          }
        },
        child: GestureDetector(
          // Dismiss keyboard when tapping outside of text fields
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            // Use resizeToAvoidBottomInset to handle keyboard appearance
            resizeToAvoidBottomInset: true,
            body: GradientBackground(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF121212),
                  Color(0xFF0A0A0A),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          AuthFormRedesign(
                            onSignUpTap: () => _changeTab(1),
                            onForgotPasswordTap: () => _changeTab(2),
                          ),
                          SignUpRedesign(
                            onBackToLoginTap: () => _changeTab(0),
                          ),
                          ForgotPasswordRedesign(
                            onBackToLoginTap: () => _changeTab(0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x4D000000), // Black with 30% opacity
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x1AFFFFFF), // White with 10% opacity
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A6C63FF), // accentPrimary with 10% opacity
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              AnimatedOpacity(
                opacity: _currentIndex == 0 ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: textWhite,
                  onPressed: _currentIndex == 0 ? null : () => _changeTab(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: Text(
                    _getTitle(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textWhite,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),
      ),
    );
  }
}
