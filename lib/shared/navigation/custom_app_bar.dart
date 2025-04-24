import 'package:flutter/material.dart';
import 'package:biftech/shared/theme/colors.dart'; // Assuming theme colors

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Pass scroll offset for dynamic effects

  const CustomAppBar({
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor, // Default will be handled below
    this.scrollOffset = 0.0, // Default to 0
    super.key,
  });
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor; // Allow overriding background
  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine background opacity based on scroll offset
    final opacity = (scrollOffset / 100.0)
        .clamp(0.0, 0.85); // Becomes 85% opaque after 100px scroll
    // Use imported secondaryBackground directly
    //(assuming it's non-nullable based on previous error)
    const baseBgColor = secondaryBackground;
    final effectiveBackgroundColor =
        backgroundColor ?? baseBgColor.withAlpha((opacity * 255).round());

    // Determine title scale based on scroll offset
    final titleScale =
        (1.0 - (scrollOffset / 200.0)).clamp(0.85, 1.0); // Shrinks to 85% size

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      elevation:
          scrollOffset > 10 ? 4.0 : 0.0, // Add elevation only when scrolled
      shadowColor: Colors.black.withAlpha((0.3 * 255).round()),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading ? const CustomBackButton() : null,
      title: Transform.scale(
        scale: titleScale,
        alignment: Alignment.centerLeft, // Keep title aligned left when scaling
        child: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            // Use theme color for text on AppBar background
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: actions,
      centerTitle: false, // Keep title left-aligned
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomBackButton extends StatefulWidget {
  const CustomBackButton({super.key});

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    _controller.forward();
  }

  void _handleTapUp() {
    _controller.reverse().then((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque, // Make sure the area is tappable
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          // Add padding/margin if needed for better tap area
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new, // Use standard iOS back icon
            // Use theme color for icon on AppBar background
            color: colorScheme.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}
