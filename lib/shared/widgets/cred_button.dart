import 'package:biftech/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template cred_button}
/// A custom button with CRED-style design.
/// {@endtemplate}
class CredButton extends StatefulWidget {
  /// {@macro cred_button}
  const CredButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.elevation = 4,
    super.key,
  });

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The label text for the button.
  final String label;

  /// The icon to display.
  final IconData? icon;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// The gradient to use for the button background.
  final Gradient? gradient;

  /// The background color to use for the button.
  final Color? backgroundColor;

  /// The foreground color to use for the button.
  final Color? foregroundColor;

  /// The width of the button.
  final double? width;

  /// The height of the button.
  final double height;

  /// The border radius of the button.
  final double borderRadius;

  /// The elevation of the button.
  final double elevation;

  @override
  State<CredButton> createState() => _CredButtonState();
}

class _CredButtonState extends State<CredButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.mediumImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  bool get _isEnabled => widget.isEnabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = widget.backgroundColor ?? accentPrimary;
    final defaultForegroundColor = widget.foregroundColor ?? textWhite;

    return AnimatedScale(
      scale: _scaleAnimation.value,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedOpacity(
          opacity: _isEnabled ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: _isEnabled ? widget.gradient : null,
              color: _isEnabled
                  ? (widget.gradient != null ? null : defaultBackgroundColor)
                  : inactive,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isEnabled && !_isPressed
                  ? [
                      // Main shadow
                      BoxShadow(
                        color: const Color(
                          0x4D6C63FF,
                        ), // accentPrimary with 30% opacity
                        blurRadius: widget.elevation * 2,
                        offset: Offset(0, widget.elevation),
                      ),
                      // Glow effect
                      BoxShadow(
                        color: const Color(
                          0x336C63FF,
                        ), // accentPrimary with 20% opacity
                        blurRadius: widget.elevation * 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Shimmer effect
                if (_isEnabled && !_isPressed && widget.gradient != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: _buildShimmerEffect(),
                    ),
                  ),
                // Button content
                Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              defaultForegroundColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: defaultForegroundColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: defaultForegroundColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x00FFFFFF), // White with 0% opacity
            Color(0x33FFFFFF), // White with 20% opacity
            Color(0x00FFFFFF), // White with 0% opacity
          ],
          stops: [0.0, 0.5, 1.0],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.transparent,
              Color(0x0DFFFFFF), // White with 5% opacity
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// {@template cred_secondary_button}
/// A secondary button with CRED-style design.
/// {@endtemplate}
class CredSecondaryButton extends StatelessWidget {
  /// {@macro cred_secondary_button}
  const CredSecondaryButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    super.key,
  });

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The label text for the button.
  final String label;

  /// The icon to display.
  final IconData? icon;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// The width of the button.
  final double? width;

  /// The height of the button.
  final double height;

  /// The border radius of the button.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return CredButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
      height: height,
      borderRadius: borderRadius,
      backgroundColor: secondaryBackground,
      foregroundColor: textWhite,
      elevation: 2,
    );
  }
}

/// {@template cred_text_button}
/// A text button with CRED-style design.
/// {@endtemplate}
class CredTextButton extends StatefulWidget {
  /// {@macro cred_text_button}
  const CredTextButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.color,
    super.key,
  });

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The label text for the button.
  final String label;

  /// The icon to display.
  final IconData? icon;

  /// The color to use for the button.
  final Color? color;

  @override
  State<CredTextButton> createState() => _CredTextButtonState();
}

class _CredTextButtonState extends State<CredTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? accentPrimary;

    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isHovered ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
