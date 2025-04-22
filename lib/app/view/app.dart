import 'package:biftech/features/auth/auth.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:biftech/features/home/home.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:biftech/features/video_feed/video_feed.dart';
import 'package:biftech/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _initialRoute = '/login';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize VideoFeedService
      await VideoFeedService.initialize();

      // Check if user is logged in
      _checkLoggedInUser();

      // Update the UI if needed
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Still mark as initialized to show the app
        });
      }
    }
  }

  void _checkLoggedInUser() {
    final authRepository = AuthService.getAuthRepository();
    if (authRepository.isLoggedIn()) {
      setState(() {
        _initialRoute = '/home';
      });
    }
  }

  /// Generate routes for the app
  Route<dynamic> _generateRoute(RouteSettings settings) {
    debugPrint('Generating route: ${settings.name}');

    // Extract route name
    final routeName = settings.name ?? '/';

    // Handle routes
    switch (routeName) {
      case '/login':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const AuthPage(),
        );
      case '/home':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const HomePage(),
        );
      case '/video-feed':
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const VideoFeedPage(),
        );
      default:
        // Handle dynamic routes
        if (routeName.startsWith('/flowchart/')) {
          // Extract the ID from the route
          final id = routeName.replaceFirst('/flowchart/', '');
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Flowchart')),
              body: Center(child: Text('Flowchart ID: $id')),
            ),
          );
        }

        // If no route match is found, show a 404 page
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '404 - Page Not Found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Route "$routeName" does not exist'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
      onGenerateRoute: _generateRoute,
      // Add home route as a fallback
      home: const HomePage(),
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '404 - Page Not Found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Route "${settings.name}" does not exist'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
