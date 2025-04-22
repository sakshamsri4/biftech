import 'package:biftech/features/auth/cubit/auth_cubit.dart';
import 'package:biftech/features/auth/view/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template auth_page}
/// A page that allows users to log in.
/// {@endtemplate}
class AuthPage extends StatelessWidget {
  /// {@macro auth_page}
  const AuthPage({super.key});

  /// The route name for this page.
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside of text fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // Use resizeToAvoidBottomInset to handle keyboard appearance
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Login'),
          // Make the app bar responsive
          toolbarHeight: MediaQuery.of(context).size.height > 600 ? 56 : 48,
        ),
        body: SafeArea(
          // Use SafeArea to handle notches and system UI elements
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocProvider(
            create: (_) => AuthCubit(),
            child: const AuthForm(),
          ),
        ),
      ),
    );
  }
}
