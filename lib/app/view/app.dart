import 'package:biftech/features/auth/auth.dart';
import 'package:biftech/features/home/home.dart';
import 'package:biftech/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
