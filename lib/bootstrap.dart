import 'dart:async';
import 'dart:developer';

import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Ensure Flutter binding is initialized before accessing platform services
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize services
  try {
    await AuthService.initialize();
  } catch (e) {
    log(
      'Failed to initialize AuthService: $e',
      stackTrace: StackTrace.current,
    );
    // Fallback behavior: Create an in-memory repository
    // that doesn't persist data. This allows the app to run,
    // but user will need to log in again after restart
    await AuthService.initializeWithFallback();
  }

  // Add cross-flavor configuration here

  runApp(await builder());
}
