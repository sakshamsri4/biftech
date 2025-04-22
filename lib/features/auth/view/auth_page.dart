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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocProvider(
          create: (_) => AuthCubit(),
          child: const AuthForm(),
        ),
      ),
    );
  }
}
