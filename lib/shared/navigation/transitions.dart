import 'package:flutter/material.dart';

// --- Fade Transition ---
class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration:
              const Duration(milliseconds: 300), // Standard fade duration
        );
  final Widget page;
}

// --- Slide Up Transition (Modal Style) ---
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic; // Smooth easing

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 400), // Slightly longer for slide
        );
  final Widget page;
}

// --- No Transition (Useful for initial routes or specific cases) ---
class NoTransitionRoute<T> extends PageRouteBuilder<T> {
  NoTransitionRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
  final Widget page;
}

// --- Notes on Other Transitions ---
// Hero Transitions: Implemented directly using the `Hero` widget around
//                   shared elements on both the source and destination screens.
//                   No specific PageRoute needed for the basic Hero effect.

// Page Curl Effect: This is significantly more complex and often requires
//                   platform-specific implementations or dedicated packages.
//                   It's not a standard Flutter transition.

// Spring Physics: Can be integrated into transitionsBuilder using
//                 `SpringSimulation` and `AnimationController`,
// but adds complexity.
//                 The `Curves.elasticOut` or similar curves can provide a
//                 spring-like feel with less code.
