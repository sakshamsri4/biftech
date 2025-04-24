import 'package:flutter/material.dart';

class GradientProgressIndicator extends StatelessWidget {
  const GradientProgressIndicator({
    required this.value,
    this.gradient = const LinearGradient(
      colors: [Colors.blueAccent, Colors.lightBlueAccent],
    ),
    this.backgroundColor = Colors.black26,
    this.height = 8.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    super.key,
  });

  final double value; // 0.0 to 1.0
  final Gradient gradient;
  final Color backgroundColor;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final progressWidth = constraints.maxWidth * value.clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      // Ensure the gradient covers the full potential width
                      return gradient.createShader(
                        Rect.fromLTWH(
                          0,
                          0,
                          constraints.maxWidth,
                          bounds.height,
                        ),
                      );
                    },
                    child: Container(
                      width: progressWidth,
                      decoration: BoxDecoration(
                        // This color is arbitrary,
                        //the ShaderMask provides the gradient
                        color: Colors.white,
                        borderRadius: borderRadius,
                      ),
                    ),
                  ),
                ),
                // Align the visible progress part
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: progressWidth,
                    // This container clips
                    // the ShaderMask output to the progress value
                    // It doesn't need its
                    // own color or decoration if clipped correctly.
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
