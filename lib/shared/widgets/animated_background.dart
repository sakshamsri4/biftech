import 'dart:math' as math;
import 'dart:ui';
import 'package:biftech/shared/theme/colors.dart';
import 'package:flutter/material.dart';

/// {@template animated_background}
/// An animated background with floating particles.
/// {@endtemplate}
class AnimatedBackground extends StatefulWidget {
  /// {@macro animated_background}
  const AnimatedBackground({
    this.particleCount = 20,
    this.colors,
    super.key,
  });

  /// The number of particles to display.
  final int particleCount;

  /// The colors to use for the particles.
  final List<Color>? colors;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<ParticleModel> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final defaultColors = [
      accentPrimary.withAlpha(128), // 0.5 opacity
      accentSecondary.withAlpha(128), // 0.5 opacity
      const Color(0xFF9C27B0).withAlpha(128), // 0.5 opacity
      const Color(0xFF673AB7).withAlpha(128), // 0.5 opacity
    ];

    final colors = widget.colors ?? defaultColors;
    final random = math.Random();

    _particles = List.generate(
      widget.particleCount,
      (index) => ParticleModel(
        position: Offset(
          random.nextDouble(),
          random.nextDouble(),
        ),
        speed: Offset(
          (random.nextDouble() - 0.5) * 0.02,
          (random.nextDouble() - 0.5) * 0.02,
        ),
        size: 5.0 + random.nextDouble() * 15,
        color: colors[random.nextInt(colors.length)],
        shape: random.nextInt(3),
      ),
    );
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
        // Update particle positions
        for (final particle in _particles) {
          particle.position += particle.speed;

          // Bounce off edges
          if (particle.position.dx < 0 || particle.position.dx > 1) {
            particle.speed = Offset(-particle.speed.dx, particle.speed.dy);
          }
          if (particle.position.dy < 0 || particle.position.dy > 1) {
            particle.speed = Offset(particle.speed.dx, -particle.speed.dy);
          }
        }

        return CustomPaint(
          painter: ParticlePainter(particles: _particles),
          child: child,
        );
      },
      child: Container(),
    );
  }
}

/// A model for a particle in the animated background.
class ParticleModel {
  /// Creates a particle model.
  ParticleModel({
    required this.position,
    required this.speed,
    required this.size,
    required this.color,
    required this.shape,
  });

  /// The position of the particle (0-1 range).
  Offset position;

  /// The speed of the particle.
  Offset speed;

  /// The size of the particle.
  final double size;

  /// The color of the particle.
  final Color color;

  /// The shape of the particle (0: circle, 1: square, 2: triangle).
  final int shape;
}

/// A painter for the particles.
class ParticlePainter extends CustomPainter {
  /// Creates a particle painter.
  ParticlePainter({required this.particles});

  /// The particles to paint.
  final List<ParticleModel> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.srcOver;

      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(position, particle.size, paint);
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: position,
              width: particle.size * 2,
              height: particle.size * 2,
            ),
            paint,
          );
        case 2: // Triangle
          final path = Path()
            ..moveTo(position.dx, position.dy - particle.size)
            ..lineTo(position.dx + particle.size, position.dy + particle.size)
            ..lineTo(position.dx - particle.size, position.dy + particle.size)
            ..close();
          canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

/// {@template gradient_background}
/// A gradient background with a blur effect.
/// {@endtemplate}
class GradientBackground extends StatelessWidget {
  /// {@macro gradient_background}
  const GradientBackground({
    required this.child,
    this.gradient,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// The gradient to use for the background.
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                primaryBackground,
                Color(0xFF0A0A0A),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
      ),
      child: Stack(
        children: [
          const AnimatedBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: child,
          ),
        ],
      ),
    );
  }
}
