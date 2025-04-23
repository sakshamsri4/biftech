import 'package:biftech/features/flowchart/cubit/flowchart_cubit.dart';
import 'package:biftech/features/winner/cubit/winner_cubit.dart';
import 'package:biftech/features/winner/cubit/winner_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopop/neopop.dart';

/// Page for declaring a winner and showing the distribution
class WinnerPage extends StatelessWidget {
  /// Constructor
  const WinnerPage({
    required this.videoId,
    super.key,
  });

  /// ID of the video this flowchart is for
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Get the FlowchartCubit from the parent
        final flowchartCubit = context.read<FlowchartCubit>();

        // Create a WinnerCubit with the FlowchartCubit
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
                child: CircularProgressIndicator(),
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
                    Text(state.error ?? 'Something went wrong'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WinnerCubit>().declareWinner();
                      },
                      child: const Text('Try Again'),
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
          Icon(
            Icons.emoji_events,
            size: 80,
            color: Colors.amber.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Declare a Winner',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Declare a winner for the current discussion. '
              'The node with the highest score (donations + comments) will win.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          NeoPopButton(
            color: Colors.amber.shade300,
            onTapUp: () {
              context.read<WinnerCubit>().declareWinner();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text(
                'Declare Winner',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
        child: CircularProgressIndicator(),
      );
    }

    // Format the remaining time
    final minutes = remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    final formattedTime = '$minutes:$seconds';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.timer,
                  size: 60,
                  color: Colors.blue.shade300,
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
                  value: 1 - (remainingTime.inSeconds / 10), // Assuming 10 seconds total
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
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
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    winner.winningNode.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBadge(
                        Icons.volunteer_activism,
                        '${winner.winningNode.donation.toInt()}',
                        Colors.green.shade100,
                        Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        Icons.comment,
                        '${winner.winningNode.comments.length}',
                        Colors.amber.shade100,
                        Colors.amber.shade700,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        Icons.score,
                        '${winner.winningNode.score}',
                        Colors.blue.shade100,
                        Colors.blue.shade700,
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
            child: _buildDistributionChart(winner),
          ),
          const SizedBox(height: 24),
          Center(
            child: NeoPopButton(
              color: Colors.red.shade300,
              onTapUp: () {
                context.read<WinnerCubit>().cancelEvaluation();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Text(
                  'Cancel Evaluation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, WinnerState state) {
    final winner = state.winner;
    if (winner == null) {
      return const Center(
        child: Text('No winner data available'),
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
                Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber.shade400,
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
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    winner.winningNode.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBadge(
                        Icons.volunteer_activism,
                        '${winner.winningNode.donation.toInt()}',
                        Colors.green.shade100,
                        Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        Icons.comment,
                        '${winner.winningNode.comments.length}',
                        Colors.amber.shade100,
                        Colors.amber.shade700,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        Icons.score,
                        '${winner.winningNode.score}',
                        Colors.blue.shade100,
                        Colors.blue.shade700,
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
            child: _buildDistributionChart(winner),
          ),
          const SizedBox(height: 16),
          _buildDistributionDetails(winner),
          const SizedBox(height: 32),
          Center(
            child: NeoPopButton(
              color: Colors.blue.shade400,
              onTapUp: () {
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Text(
                  'Back to Flowchart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    IconData icon,
    String value,
    Color backgroundColor,
    Color textColor,
  ) {
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
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(WinnerModel winner) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: winner.winnerShare,
            title: '60%',
            color: Colors.green.shade400,
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          PieChartSectionData(
            value: winner.appShare,
            title: '20%',
            color: Colors.blue.shade400,
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          PieChartSectionData(
            value: winner.platformShare,
            title: '20%',
            color: Colors.amber.shade400,
            radius: 80,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        startDegreeOffset: 180,
      ),
    );
  }

  Widget _buildDistributionDetails(WinnerModel winner) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDistributionRow(
              'Winner (60%)',
              winner.winnerShare,
              Colors.green.shade400,
            ),
            const SizedBox(height: 8),
            _buildDistributionRow(
              'App Contribution (20%)',
              winner.appShare,
              Colors.blue.shade400,
            ),
            const SizedBox(height: 8),
            _buildDistributionRow(
              'Platform Margin (20%)',
              winner.platformShare,
              Colors.amber.shade400,
            ),
            const Divider(height: 24),
            _buildDistributionRow(
              'Total',
              winner.totalDonations,
              Colors.grey.shade700,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
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
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
