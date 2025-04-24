import 'dart:async';
import 'dart:ui'; // Import for ImageFilter

import 'package:biftech/features/donation/donation.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/video_feed/model/video_model.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
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
  bool _isLoading = true;
  late StreamController<Map<String, NodeModel?>> _flowchartsController;
  late Stream<Map<String, NodeModel?>> _flowchartsStream;
  Timer? _refreshTimer;
  final Map<String, FlowchartCubit> _flowchartCubits = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _flowchartsController.close();
    _refreshTimer?.cancel();
    for (final cubit in _flowchartCubits.values) {
      cubit.close();
    }
    _flowchartCubits.clear();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final videos = await VideoFeedService.instance.getVideos();
      _videos = videos;
      _setupFlowchartsStream(videos);
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

  void _setupFlowchartsStream(List<VideoModel> videos) {
    _flowchartsController =
        StreamController<Map<String, NodeModel?>>.broadcast();
    _flowchartsStream = _flowchartsController.stream;

    Future<void> loadFlowcharts() async {
      final flowcharts = <String, NodeModel?>{};
      await Future.wait(
        videos.map((video) async {
          try {
            if (!_flowchartCubits.containsKey(video.id)) {
              final cubit = FlowchartCubit(
                repository: FlowchartRepository.instance,
                videoId: video.id,
              );
              cubit.commentStream.listen((_) {
                loadFlowcharts();
              });
              _flowchartCubits[video.id] = cubit;
              await cubit.loadFlowchart();
            }
            final flowchart = await FlowchartRepository.instance
                .getFlowchartForVideo(video.id);
            flowcharts[video.id] = flowchart;
          } catch (e) {
            debugPrint('Error loading flowchart for video ${video.id}: $e');
            flowcharts[video.id] = null;
          }
        }),
      );

      if (!_flowchartsController.isClosed) {
        _flowchartsController.add(flowcharts);
      }
    }

    loadFlowcharts();

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadFlowcharts();
    });
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.white,
        backgroundColor: Colors.grey[800],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'No Discussions Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Engage with videos to start or join discussions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<Map<String, NodeModel?>>(
      stream: _flowchartsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !_isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (!snapshot.hasData && _isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final flowcharts = snapshot.data ?? {};

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildDonationStats(flowcharts),
                    const SizedBox(height: 30),
                    _buildDonationList(flowcharts),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Donation Hub',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Amplify the arguments you believe in.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
        ),
      ],
    );
  }

  Widget _buildDonationStats(Map<String, NodeModel?> flowcharts) {
    var totalDonations = 0.0;
    var totalFlowcharts = 0;

    for (final flowchart in flowcharts.values) {
      if (flowchart != null) {
        totalFlowcharts++;
        totalDonations += _calculateTotalDonations(flowchart);
      }
    }
    final formattedDonation = _formatCurrency(totalDonations);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Raised',
                  formattedDonation,
                  Icons.show_chart_rounded,
                  Colors.greenAccent.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Active Discussions',
                  totalFlowcharts.toString(),
                  Icons.forum_outlined,
                  Colors.blueAccent.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${value.toStringAsFixed(0)}';
    }
  }

  Widget _buildDonationList(Map<String, NodeModel?> flowcharts) {
    final videosWithFlowcharts = _videos.where((video) {
      return flowcharts.containsKey(video.id) && flowcharts[video.id] != null;
    }).toList();

    videosWithFlowcharts.sort((a, b) {
      final donationA = _calculateTotalDonations(flowcharts[a.id]!);
      final donationB = _calculateTotalDonations(flowcharts[b.id]!);
      return donationB.compareTo(donationA);
    });

    if (videosWithFlowcharts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 60,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Discussions Found',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by watching videos and sharing your views.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Support a Discussion',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videosWithFlowcharts.length,
          itemBuilder: (context, index) {
            final video = videosWithFlowcharts[index];
            final flowchart = flowcharts[video.id];

            if (flowchart == null) return const SizedBox.shrink();

            final totalDonations = _calculateTotalDonations(flowchart);
            final winningNode = _findWinningNode(flowchart);

            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 0,
              color: Colors.grey[900]?.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[800]!),
              ),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(
                    context,
                    '/flowchart/${video.id}',
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.videocam_off_outlined,
                                    color: Colors.grey[600],
                                    size: 28,
                                  ),
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
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'by ${video.creator}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildWinningArgumentSection(winningNode),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Raised',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(totalDonations),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          _buildGradientButton(
                            text: 'Support',
                            icon: Icons.favorite_border,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _showDonationModal(context, flowchart);
                            },
                            gradient: LinearGradient(
                              colors: [
                                Colors.greenAccent.shade400,
                                Colors.tealAccent.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildWinningArgumentSection(NodeModel winningNode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Colors.amber.shade300,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Leading Argument',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber.shade300,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            winningNode.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                'Score: ${winningNode.score}',
                Colors.blueAccent.withOpacity(0.2),
                Colors.blueAccent.shade100,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                '₹${_formatCurrency(winningNode.donation)}',
                Colors.greenAccent.withOpacity(0.2),
                Colors.greenAccent.shade100,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                '${winningNode.comments.length} comments',
                Colors.purpleAccent.withOpacity(0.2),
                Colors.purpleAccent.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black87, size: 16),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDonationModal(
    BuildContext context,
    NodeModel rootNode,
  ) async {
    final winningNode = _findWinningNode(rootNode);
    final nodeId = winningNode.id;
    final videoId = rootNode.id.replaceFirst('root_', '');

    try {
      final currentDonation = winningNode.donation;
      final flowchartCubit = _flowchartCubits[videoId] ??
          FlowchartCubit(
            repository: FlowchartRepository.instance,
            videoId: videoId,
          );

      if (!_flowchartCubits.containsKey(videoId)) {
        _flowchartCubits[videoId] = flowchartCubit;
        flowchartCubit.commentStream.listen((_) {
          _refreshData();
        });
        await flowchartCubit.loadFlowchart();
      }

      if (!context.mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: MultiBlocProvider(
              providers: [
                BlocProvider<FlowchartCubit>.value(value: flowchartCubit),
                BlocProvider<DonationCubit>(
                    create: (context) => DonationCubit()),
              ],
              child: DonationModal(
                nodeId: nodeId,
                nodeText: winningNode.text,
                currentDonation: currentDonation,
                onDonationComplete: (amount) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✨ Donation of ₹${amount.toStringAsFixed(1)} received!',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      backgroundColor: Colors.greenAccent.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(10),
                    ),
                  );

                  final updateLoadingOverlay =
                      _showLoadingOverlay(context, isModal: true);
                  try {
                    final newAmount = currentDonation + amount;
                    await flowchartCubit.updateNodeDonation(nodeId, newAmount);
                    await _refreshData();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update donation: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } finally {
                    updateLoadingOverlay.remove();
                  }
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error preparing donation: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  OverlayEntry _showLoadingOverlay(BuildContext context,
      {bool isModal = false}) {
    final overlay = OverlayEntry(
      builder: (context) => ColoredBox(
        color: isModal
            ? Colors.black.withOpacity(0.5)
            : Colors.black.withOpacity(0.7),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
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
        if (winningNode.donation > highestNode.donation) {
          highestNode = winningNode;
        } else if (winningNode.donation == highestNode.donation &&
            winningNode.createdAt.isBefore(highestNode.createdAt)) {
          highestNode = winningNode;
        }
      }
    }
    return highestNode;
  }
}
