import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavItem {
  NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class CredBottomNavBar extends StatefulWidget {
  const CredBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<CredBottomNavBar> createState() => _CredBottomNavBarState();
}

class _CredBottomNavBarState extends State<CredBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: _animationDuration,
        value: index == widget.currentIndex
            ? 1.0
            : 0.0, // Start selected item scaled up
      ),
    );
    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 0.9, end: 1.1).animate(
            // Subtle scale range
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();
  }

  @override
  void didUpdateWidget(covariant CredBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      // Ensure controllers are initialized before accessing them
      if (_animationControllers.isNotEmpty &&
          oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      if (_animationControllers.isNotEmpty &&
          widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Floating effect using Padding/Margin
    return Padding(
      padding: const EdgeInsets.all(12), // Margin around the bar
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 65, // Adjust height as needed
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(
                  (0.75 * 255).round()), // Dark semi-transparent background
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    (0.2 * 255).round(),
                  ), // 8px elevation equivalent shadow
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final isSelected = index == widget.currentIndex;
                final color = isSelected
                    ? theme.colorScheme.primary // Use theme's primary color
                    : theme.colorScheme.onSurface.withAlpha(
                        (0.7 * 255).round()); // Use theme color with alpha

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact(); // Haptic feedback
                      widget.onTap(index);
                    },
                    behavior:
                        HitTestBehavior.opaque, // Ensure full area is tappable
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimations[index],
                          child: Icon(item.icon, color: color, size: 26),
                        ),
                        const SizedBox(height: 2),
                        // Simple indicator: change label color or add a small dot/line
                        // Here, we rely on icon color and scale
                        Text(
                          item.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Optional: Add a small indicator line
                        AnimatedContainer(
                          duration: _animationDuration,
                          height: 2,
                          width: isSelected ? 16 : 0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme
                                .primary, // Use theme's primary color
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
