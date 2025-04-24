import 'package:biftech/features/flowchart/cubit/flowchart_cubit.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/features/winner/cubit/winner_cubit.dart';
import 'package:biftech/features/winner/cubit/winner_state.dart';
import 'package:biftech/features/winner/model/winner_model.dart';
import 'package:biftech/shared/animations/fade_in_animation.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/buttons/primary_button.dart';
import 'package:biftech/shared/widgets/buttons/secondary_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page for declaring a winner and showing the distribution
class WinnerPageRedesign extends StatelessWidget {
  /// Constructor
  const WinnerPageRedesign({
    required this.videoId,
    required this.flowchartCubit,
    super.key,
  });

  /// ID of the video this flowchart is for
  final String videoId;

  /// The FlowchartCubit instance
  final FlowchartCubit flowchartCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Create a WinnerCubit with the provided FlowchartCubit
        return WinnerCubit(
          flowchartCubit: flowchartCubit,
        );
      },
      child: const WinnerViewRedesign(),
    );
  }
}

/// Main view for the winner page
class WinnerViewRedesign extends StatelessWidget {
  /// Constructor
  const WinnerViewRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        backgroundColor: secondaryBackground,
        title: const Text('Declare Winner'),
        foregroundColor: textWhite,
        elevation: 0,
      ),
      body: BlocBuilder<WinnerCubit, WinnerState>(
        builder: (context, state) {
          switch (state.status) {
            case WinnerStatus.initial:
              return _buildInitialView(context);
            case WinnerStatus.loading:
              return _buildLoadingView();
            case WinnerStatus.waiting:
              return _buildWaitingView(context, state);
            case WinnerStatus.success:
              return _buildSuccessView(context, state);
            case WinnerStatus.failure:
              return _buildErrorView(context, state);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Custom loading animation
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: accentPrimary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          FadeInAnimation(
            delay: Duration(milliseconds: 300),
            child: Text(
              'Analyzing arguments...',
              style: TextStyle(
                color: textWhite70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WinnerState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with animation
            const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Declare Winner',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textWhite,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              state.error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textWhite70,
                  ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Try Again',
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.read<WinnerCubit>().declareWinner();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: _buildTrophyIcon(),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Declare a Winner',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: textWhite,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
                  ),
                ),
                child: Text(
                  'The node with the highest score\n'
                  '(donations + comments) will be declared the winner.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textWhite70,
                        height: 1.5,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDistributionExplanation(context),
            const SizedBox(height: 40),
            Center(
              child: PrimaryButton(
                label: 'Declare Winner',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.read<WinnerCubit>().declareWinner();
                },
                icon: Icons.emoji_events_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionExplanation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donation Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textWhite,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildDistributionRow(
            context,
            'Winner',
            '60%',
            success,
          ),
          const SizedBox(height: 12),
          _buildDistributionRow(
            context,
            'App Contribution',
            '20%',
            accentPrimary,
          ),
          const SizedBox(height: 12),
          _buildDistributionRow(
            context,
            'Platform Margin',
            '20%',
            warning,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    String label,
    String percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textWhite70,
                ),
          ),
        ),
        Text(
          percentage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textWhite,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildTrophyIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: secondaryBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000), // Black with 20% opacity
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Icon(
            Icons.emoji_events_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingView(BuildContext context, WinnerState state) {
    final remainingTime = state.remainingTime;
    final winner = state.winner;

    if (remainingTime == null || winner == null) {
      return _buildLoadingView();
    }

    // Format the remaining time
    final minutes =
        remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    final formattedTime = '$minutes:$seconds';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                          0x4D8A84FF,), // accentSecondary with 30% opacity
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.timer,
                      size: 48,
                      color: accentSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Evaluation in Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(
                          0x4D8A84FF,), // accentSecondary with 30% opacity
                    ),
                  ),
                  child: Text(
                    'Time remaining: $formattedTime',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: accentSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 1 -
                        (remainingTime.inSeconds /
                            10), // Assuming 10 seconds total
                    minHeight: 8,
                    backgroundColor: inactive,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(accentSecondary),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Text(
            'Current Leading Argument',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textWhite,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildArgumentCard(context, winner.winningNode),
          const SizedBox(height: 32),
          Text(
            'Projected Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textWhite,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildDistributionChart(context, winner),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Cancel',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.read<WinnerCubit>().cancelEvaluation();
                  },
                  icon: Icons.close_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: 'Speed Up',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.read<WinnerCubit>().speedUpTimer();
                  },
                  icon: Icons.fast_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, WinnerState state) {
    final winner = state.winner;
    if (winner == null) {
      return Center(
        child: Text(
          'No winner data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textWhite70,
              ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                _buildAnimatedTrophy(),
                const SizedBox(height: 24),
                Text(
                  'Winner Declared!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: textWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Text(
            'Winning Argument',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textWhite,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildArgumentCard(context, winner.winningNode),
          const SizedBox(height: 32),
          Text(
            'Donation Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textWhite,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildDistributionChart(context, winner),
          const SizedBox(height: 16),
          _buildDistributionDetails(context, winner),
          const SizedBox(height: 32),
          Center(
            child: PrimaryButton(
              label: 'Back to Flowchart',
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
              },
              icon: Icons.arrow_back_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTrophy() {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(
        color: secondaryBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000), // Black with 20% opacity
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        gradient: RadialGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
          radius: 0.8,
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Icon(
            Icons.emoji_events_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildArgumentCard(BuildContext context, NodeModel winningNode) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000), // Black with 20% opacity
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              winningNode.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textWhite,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatBadge(
                  context,
                  Icons.volunteer_activism,
                  '${winningNode.donation.toInt()}',
                  const Color(0x2600B07C), // success with 15% opacity
                  success,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  context,
                  Icons.comment,
                  '${winningNode.comments.length}',
                  const Color(0x26FFC043), // warning with 15% opacity
                  warning,
                ),
                const SizedBox(width: 12),
                _buildStatBadge(
                  context,
                  Icons.score,
                  '${winningNode.score}',
                  const Color(0x266C63FF), // accentPrimary with 15% opacity
                  accentPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    IconData icon,
    String value,
    Color backgroundColor,
    Color textColor,
  ) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ) ??
        TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(BuildContext context, WinnerModel winner) {
    final titleStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textWhite,
              fontWeight: FontWeight.bold,
            ) ??
        const TextStyle(
          color: textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
        ),
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: winner.winnerShare,
              title: '60%',
              color: success,
              radius: 100,
              titleStyle: titleStyle,
              badgeWidget: _buildPieChartBadge(Icons.emoji_events_rounded),
              badgePositionPercentageOffset: 0.9,
            ),
            PieChartSectionData(
              value: winner.appShare,
              title: '20%',
              color: accentPrimary,
              radius: 100,
              titleStyle: titleStyle,
              badgeWidget: _buildPieChartBadge(Icons.apps_rounded),
              badgePositionPercentageOffset: 0.9,
            ),
            PieChartSectionData(
              value: winner.platformShare,
              title: '20%',
              color: warning,
              radius: 100,
              titleStyle: titleStyle,
              badgeWidget: _buildPieChartBadge(Icons.devices_rounded),
              badgePositionPercentageOffset: 0.9,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          centerSpaceColor: secondaryBackground,
          startDegreeOffset: 270,
        ),
      ),
    );
  }

  Widget _buildPieChartBadge(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: secondaryBackground,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 16,
          color: textWhite70,
        ),
      ),
    );
  }

  Widget _buildDistributionDetails(BuildContext context, WinnerModel winner) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDistributionDetailRow(
              context,
              'Winner (60%)',
              '₹${winner.winnerShare.toStringAsFixed(2)}',
              success,
            ),
            const SizedBox(height: 12),
            _buildDistributionDetailRow(
              context,
              'App Contribution (20%)',
              '₹${winner.appShare.toStringAsFixed(2)}',
              accentPrimary,
            ),
            const SizedBox(height: 12),
            _buildDistributionDetailRow(
              context,
              'Platform Margin (20%)',
              '₹${winner.platformShare.toStringAsFixed(2)}',
              warning,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                color: Color(0xFF2A2A2A),
                height: 1,
              ),
            ),
            _buildDistributionDetailRow(
              context,
              'Total',
              '₹${winner.totalDonations.toStringAsFixed(2)}',
              textWhite,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionDetailRow(
    BuildContext context,
    String label,
    String amount,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isBold ? textWhite : textWhite70,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isBold ? textWhite : color,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
