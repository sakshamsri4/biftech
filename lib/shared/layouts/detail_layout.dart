import 'package:flutter/material.dart';

class DetailLayout extends StatelessWidget {
  const DetailLayout({
    required this.header,
    required this.title,
    required this.slivers,
    this.stickyBottomActions,
    this.headerBackgroundColor,
    this.physics,
    super.key,
  });
  final Widget header; // Widget for the flexible space (e.g., Image)
  final String title; // Title for the SliverAppBar
  final List<Widget>
      slivers; // Content slivers (e.g., SliverList, SliverToBoxAdapter)
  final Widget? stickyBottomActions; // Optional actions fixed at the bottom
  final Color? headerBackgroundColor;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget body = CustomScrollView(
      physics: physics ?? const BouncingScrollPhysics(), // Smooth physics
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 250, // Adjust as needed
          pinned: true, // Keep AppBar visible when scrolling up
          stretch: true, // Allow stretching on overscroll
          backgroundColor: headerBackgroundColor ?? theme.colorScheme.surface,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface, // Ensure contrast
                fontSize: 16, // Smaller pinned title
              ),
            ),
            background: header, // Parallax effect happens here
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
            ],
          ),
        ),
        // Content slivers that scroll "over" the header
        ...slivers,
        // Add padding at the bottom if sticky actions exist,
        // so content doesn't hide behind them.
        if (stickyBottomActions != null)
          const SliverPadding(
              padding: EdgeInsets.only(
                  bottom: 80)), // Adjust height based on actions
      ],
    );

    if (stickyBottomActions != null) {
      // Wrap ScrollView and Actions in a Stack for sticky effect
      return Scaffold(
        // Scaffold needed if actions include FAB etc.
        body: Stack(
          children: [
            body, // The CustomScrollView
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // Add background/padding for actions if needed
                color:
                    theme.canvasColor.withOpacity(0.95), // Slight transparency
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  // Avoid intrusions
                  top: false, // Only bottom safe area
                  child: stickyBottomActions!,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // If no sticky actions, just return the CustomScrollView
      // Wrap in Scaffold if AppBar actions etc. are needed at the top level
      return Scaffold(body: body);
    }
  }
}
