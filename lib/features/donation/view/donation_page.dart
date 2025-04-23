import 'package:biftech/features/donation/donation.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/video_feed/model/video_model.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopop/neopop.dart';

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
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24), // More generous padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NeoPopShimmer(
                  shimmerColor: Colors.green.shade300,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.volunteer_activism,
                      size: 32,
                      color: Color(0xFF00A86B), // Vibrant green
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Center',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800, // Bolder
                                  letterSpacing:
                                      -0.5, // CRED-style tight letter spacing
                                  color: Colors.black87,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Support arguments you believe in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // More spacing
            const Text(
              'Your donations help strengthen arguments in discussions\n'
              'and reward the best contributors.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
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

    // Format the donation amount to ensure it fits
    final formattedDonation = _formatCurrency(totalDonations);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24), // More generous padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 24), // More spacing
            // Use a more responsive layout for the stats
            LayoutBuilder(
              builder: (context, constraints) {
                // If we have enough width, use a row layout
                if (constraints.maxWidth > 400) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildNeoPOPStatCard(
                          'Total',
                          formattedDonation,
                          Icons.monetization_on,
                          const Color(0xFFFF9A3D), // More vibrant amber
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildNeoPOPStatCard(
                          'Discussions',
                          totalFlowcharts.toString(),
                          Icons.account_tree,
                          const Color(0xFF4D7CFE), // More vibrant blue
                        ),
                      ),
                    ],
                  );
                } else {
                  // For smaller screens, use a column layout
                  return Column(
                    children: [
                      _buildNeoPOPStatCard(
                        'Total Donations',
                        formattedDonation,
                        Icons.monetization_on,
                        const Color(0xFFFF9A3D),
                      ),
                      const SizedBox(height: 20),
                      _buildNeoPOPStatCard(
                        'Active Discussions',
                        totalFlowcharts.toString(),
                        Icons.account_tree,
                        const Color(0xFF4D7CFE),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Format currency value to ensure it fits in the UI
  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${value.toStringAsFixed(0)}';
    }
  }

  Widget _buildNeoPOPStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Transform.rotate(
      angle: 0.02, // Slight tilt for 3D effect (about 1 degree)
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color.withAlpha(220),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 28, // Larger for emphasis
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
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
              margin: const EdgeInsets.only(bottom: 24),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/flowchart/${video.id}',
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              video.thumbnailUrl,
                              width: 120,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 120,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
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
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: Colors.black87,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'by ${video.creator}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Donations',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '₹${_formatCurrency(totalDonations)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF00A86B),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeoPopButton(
                            color: const Color(0xFF00A86B),
                            onTapUp: () {
                              _showDonationModal(context, flowchart);
                            },
                            onTapDown: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.volunteer_activism,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Donate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...[
                        const Divider(height: 32),
                        const Text(
                          'Current Winning Argument:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4D7CFE).withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                winningNode.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFF4D7CFE).withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Score: ${winningNode.score}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4D7CFE),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFF00A86B).withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '₹${_formatCurrency(
                                        winningNode.donation,
                                      )}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF00A86B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFFF9A3D).withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${winningNode.comments.length} comments',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFF9A3D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
