import 'package:biftech/features/flowchart/cubit/flowchart_cubit.dart';
import 'package:biftech/features/winner/cubit/winner_cubit.dart';
import 'package:biftech/features/winner/cubit/winner_state.dart';
import 'package:biftech/features/winner/model/winner_model.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/buttons/primary_button.dart';
import 'package:biftech/shared/widgets/cards/primary_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page for declaring a winner and showing the distribution
class WinnerPage extends StatelessWidget {
  /// Constructor
  const WinnerPage({
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
      child: const WinnerView(),
    );
  }
}

/// Main view for the winner page
class WinnerView extends StatelessWidget {
  /// Constructor
  const WinnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Declare Winner'),
      ),
      body: BlocBuilder<WinnerCubit, WinnerState>(
        builder: (context, state) {
          switch (state.status) {
            case WinnerStatus.initial:
              return _buildInitialView(context);
            case WinnerStatus.loading:
              return const Center(
                child: CircularProgressIndicator(
                  color: accentPrimary,
                ),
              );
            case WinnerStatus.waiting:
              return _buildWaitingView(context, state);
            case WinnerStatus.success:
              return _buildSuccessView(context, state);
            case WinnerStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to declare winner',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error ?? 'Something went wrong',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Try Again',
                      onPressed: () {
                        context.read<WinnerCubit>().declareWinner();
                      },
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 80,
            color: accentPrimary,
          ),
          const SizedBox(height: 24),
          Text(
            'Declare a Winner',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Declare a winner for the current discussion. '
              'The node with the highest score '
              '(donations + comments) will win.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Declare Winner',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<WinnerCubit>().declareWinner();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingView(BuildContext context, WinnerState state) {
    final remainingTime = state.remainingTime;
    final winner = state.winner;

    if (remainingTime == null || winner == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: accentPrimary,
        ),
      );
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
                const Icon(
                  Icons.timer,
                  size: 60,
                  color: accentSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Evaluation in Progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Time remaining: $formattedTime',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: 1 -
                      (remainingTime.inSeconds /
                          10), // Assuming 10 seconds total
                  minHeight: 8,
                  backgroundColor: inactive,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(accentSecondary),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Text(
            'Current Leading Argument:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          PrimaryCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    winner.winningNode.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBadge(
                        context,
                        Icons.volunteer_activism,
                        '${winner.winningNode.donation.toInt()}',
                        success.withOpacity(0.15),
                        success,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        context,
                        Icons.comment,
                        '${winner.winningNode.comments.length}',
                        warning.withOpacity(0.15),
                        warning,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        context,
                        Icons.score,
                        '${winner.winningNode.score}',
                        accentPrimary.withOpacity(0.15),
                        accentPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Projected Distribution:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildDistributionChart(context, winner),
          ),
          const SizedBox(height: 24),
          Center(
            child: PrimaryButton(
              label: 'Cancel Evaluation',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<WinnerCubit>().cancelEvaluation();
              },
            ),
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
          style: Theme.of(context).textTheme.bodyMedium,
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
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: accentPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Winner Declared!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Text(
            'Winning Argument:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          PrimaryCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    winner.winningNode.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBadge(
                        context,
                        Icons.volunteer_activism,
                        '${winner.winningNode.donation.toInt()}',
                        success.withOpacity(0.15),
                        success,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        context,
                        Icons.comment,
                        '${winner.winningNode.comments.length}',
                        warning.withOpacity(0.15),
                        warning,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        context,
                        Icons.score,
                        '${winner.winningNode.score}',
                        accentPrimary.withOpacity(0.15),
                        accentPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Donation Distribution:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildDistributionChart(context, winner),
          ),
          const SizedBox(height: 16),
          _buildDistributionDetails(context, winner),
          const SizedBox(height: 32),
          Center(
            child: PrimaryButton(
              label: 'Back to Flowchart',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
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

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: winner.winnerShare,
            title: '60%',
            color: success,
            radius: 80,
            titleStyle: titleStyle,
          ),
          PieChartSectionData(
            value: winner.appShare,
            title: '20%',
            color: accentPrimary,
            radius: 80,
            titleStyle: titleStyle,
          ),
          PieChartSectionData(
            value: winner.platformShare,
            title: '20%',
            color: warning,
            radius: 80,
            titleStyle: titleStyle,
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        startDegreeOffset: 180,
      ),
    );
  }

  Widget _buildDistributionDetails(BuildContext context, WinnerModel winner) {
    return PrimaryCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDistributionRow(
              context,
              'Winner (60%)',
              winner.winnerShare,
              success,
            ),
            const SizedBox(height: 8),
            _buildDistributionRow(
              context,
              'App Contribution (20%)',
              winner.appShare,
              accentPrimary,
            ),
            const SizedBox(height: 8),
            _buildDistributionRow(
              context,
              'Platform Margin (20%)',
              winner.platformShare,
              warning,
            ),
            const Divider(height: 24),
            _buildDistributionRow(
              context,
              'Total',
              winner.totalDonations,
              textWhite70,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ) ??
        TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: textStyle,
            ),
          ],
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: textStyle,
        ),
      ],
    );
  }
}
