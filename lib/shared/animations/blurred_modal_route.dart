import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredModalRoute<T> extends PageRoute<T> {
  BlurredModalRoute({
    required this.builder,
    this.barrierLabel,
    this.blurSigma = 5.0,
    Color? barrierColor,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 250),
    super.settings,
  }) : _barrierColor = barrierColor;

  final WidgetBuilder builder;
  final double blurSigma;
  final Color? _barrierColor;

  @override
  final String? barrierLabel;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => _barrierColor ?? Colors.black54;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurSigma * animation.value,
        sigmaY: blurSigma * animation.value,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ColoredBox(
          color: barrierColor,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showBlurredModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double blurSigma = 5.0,
  Color barrierColor = Colors.black54,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    BlurredModalRoute<T>(
      builder: builder,
      blurSigma: blurSigma,
      barrierColor: barrierColor,
      settings: routeSettings,
    ),
  );
}
