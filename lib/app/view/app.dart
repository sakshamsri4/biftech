import 'package:biftech/features/auth/auth.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:biftech/features/home/home.dart';
import 'package:biftech/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _initialRoute = '/login';

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  void _checkLoggedInUser() {
    final authRepository = AuthService.getAuthRepository();
    if (authRepository.isLoggedIn()) {
      setState(() {
        _initialRoute = '/home';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: _initialRoute,
      routes: {
        '/login': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
