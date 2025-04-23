import 'package:biftech/features/donation/donation.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/video_feed/model/video_model.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template donation_page}
/// The main donation page of the application.
/// {@endtemplate}
class DonationPage extends StatefulWidget {
  /// {@macro donation_page}
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  List<VideoModel> _videos = [];
  final Map<String, NodeModel?> _flowcharts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load videos
      final videos = await VideoFeedService.instance.getVideos();
      _videos = videos;

      // Load flowcharts for each video
      for (final video in videos) {
        try {
          final flowchart =
              await FlowchartRepository.instance.getFlowchartForVideo(video.id);
          _flowcharts[video.id] = flowchart;
        } catch (e) {
          debugPrint('Error loading flowchart for video ${video.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 80,
              color: Colors.blue.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              'No Videos Available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Watch videos to participate in discussions and donations',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDonationStats(),
          const SizedBox(height: 24),
          _buildDonationList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 30,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Center',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Support arguments you believe in',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your donations help strengthen arguments in discussions\n'
              'and reward the best contributors.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationStats() {
    // Calculate total donations
    var totalDonations = 0.0;
    var totalFlowcharts = 0;

    for (final flowchart in _flowcharts.values) {
      if (flowchart != null) {
        totalFlowcharts++;
        totalDonations += _calculateTotalDonations(flowchart);
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Donations',
                    '₹${totalDonations.toStringAsFixed(2)}',
                    Icons.monetization_on,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Active Discussions',
                    totalFlowcharts.toString(),
                    Icons.account_tree,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.withAlpha(204),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationList() {
    // Filter videos with flowcharts
    final videosWithFlowcharts = _videos.where((video) {
      return _flowcharts[video.id] != null;
    }).toList();

    if (videosWithFlowcharts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 60,
              color: Colors.blue.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Discussions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Watch videos to start discussions',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discussions to Support',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videosWithFlowcharts.length,
          itemBuilder: (context, index) {
            final video = videosWithFlowcharts[index];
            final flowchart = _flowcharts[video.id];

            if (flowchart == null) {
              return const SizedBox.shrink();
            }

            final totalDonations = _calculateTotalDonations(flowchart);
            final winningNode = _findWinningNode(flowchart);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/flowchart/${video.id}',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              video.thumbnailUrl,
                              width: 100,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'by ${video.creator}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Donations',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${totalDonations.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showDonationModal(context, flowchart);
                            },
                            icon: const Icon(Icons.volunteer_activism),
                            label: const Text('Donate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      ...[
                        const Divider(height: 24),
                        Text(
                          'Current Winning Argument:',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          winningNode.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Score: ${winningNode.score}'
                          '(₹${winningNode.donation.toStringAsFixed(2)} + '
                          '${winningNode.comments.length} comments)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showDonationModal(
    BuildContext context,
    NodeModel rootNode,
  ) async {
    // Find the winning node to donate to
    final winningNode = _findWinningNode(rootNode);
    // Use the winning node ID
    final nodeId = winningNode.id;
    // Get the video ID from the root node ID
    final videoId = rootNode.id.replaceFirst('root_', '');

    // Show a loading indicator
    final loadingOverlay = _showLoadingOverlay(context);

    try {
      // Get the current donation amount for the node
      final currentDonation = winningNode.donation;

      // Create a FlowchartCubit instance that will be used to update the node
      final flowchartCubit = FlowchartCubit(
        repository: FlowchartRepository.instance,
        videoId: videoId,
      );

      // Wait for the flowchart to load
      await flowchartCubit.loadFlowchart();

      // Hide the loading indicator
      loadingOverlay.remove();

      if (!context.mounted) return;

      // Show the donation modal
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          // Provide both FlowchartCubit and DonationCubit
          return MultiBlocProvider(
            providers: [
              BlocProvider<FlowchartCubit>.value(
                value: flowchartCubit,
              ),
              BlocProvider<DonationCubit>(
                create: (context) => DonationCubit(),
              ),
            ],
            child: DonationModal(
              nodeId: nodeId,
              onDonationComplete: (amount) async {
                // Show a loading indicator
                final updateLoadingOverlay = _showLoadingOverlay(context);

                try {
                  // Update the node with the donation amount
                  // (add to existing donation)
                  final newAmount = currentDonation + amount;
                  await flowchartCubit.updateNodeDonation(nodeId, newAmount);

                  // Refresh the data after donation
                  await _loadData();

                  // Hide the loading indicator
                  updateLoadingOverlay.remove();

                  if (!context.mounted) return;

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully donated ₹${amount.toStringAsFixed(2)}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Hide the loading indicator
                  updateLoadingOverlay.remove();

                  if (!context.mounted) return;

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update donation: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    } catch (e) {
      // Hide the loading indicator
      loadingOverlay.remove();

      if (!context.mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load flowchart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (context) => ColoredBox(
        color: Colors.black.withAlpha(128),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }

  double _calculateTotalDonations(NodeModel node) {
    var total = node.donation;

    for (final challenge in node.challenges) {
      total += _calculateTotalDonations(challenge);
    }

    return total;
  }

  NodeModel _findWinningNode(NodeModel node) {
    var highestNode = node;
    var highestScore = node.score;

    for (final challenge in node.challenges) {
      final winningNode = _findWinningNode(challenge);
      if (winningNode.score > highestScore) {
        highestNode = winningNode;
        highestScore = winningNode.score;
      } else if (winningNode.score == highestScore) {
        // Tiebreaker: earlier creation time wins
        if (winningNode.createdAt.isBefore(highestNode.createdAt)) {
          highestNode = winningNode;
        }
      }
    }

    return highestNode;
  }
}
