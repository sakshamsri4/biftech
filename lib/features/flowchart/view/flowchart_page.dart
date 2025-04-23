import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/flowchart/view/widgets/challenge_modal.dart';
import 'package:biftech/features/flowchart/view/widgets/comment_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/graphview.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

/// Page for displaying and interacting with a flowchart
class FlowchartPage extends StatelessWidget {
  /// Constructor
  const FlowchartPage({
    required this.videoId,
    super.key,
  });

  /// ID of the video this flowchart is for
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlowchartCubit(
        repository: FlowchartRepository.instance,
        videoId: videoId,
      )..loadFlowchart(),
      child: const FlowchartView(),
    );
  }
}

/// Main view for the flowchart
class FlowchartView extends StatefulWidget {
  /// Constructor
  const FlowchartView({super.key});

  @override
  State<FlowchartView> createState() => _FlowchartViewState();
}

class _FlowchartViewState extends State<FlowchartView> {
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = 100
      ..levelSeparation = 150
      ..subtreeSeparation = 150
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Flowchart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FlowchartCubit>().loadFlowchart();
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              _showWinnerDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<FlowchartCubit, FlowchartState>(
        builder: (context, state) {
          switch (state.status) {
            case FlowchartStatus.initial:
            case FlowchartStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case FlowchartStatus.failure:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load flowchart',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(state.error ?? 'Unknown error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FlowchartCubit>().loadFlowchart();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            case FlowchartStatus.success:
              if (state.rootNode == null) {
                return const Center(
                  child: Text('No flowchart available'),
                );
              }
              return _buildFlowchart(context, state);
          }
        },
      ),
    );
  }

  Widget _buildFlowchart(BuildContext context, FlowchartState state) {
    // Clear the graph and rebuild it
    graph.nodes.clear();
    graph.edges.clear();

    // Build the graph from the NodeModel tree
    _buildGraphFromTree(state.rootNode!, null);

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.01,
      maxScale: 5.6,
      child: GraphView(
        graph: graph,
        algorithm: BuchheimWalkerAlgorithm(
          builder,
          TreeEdgeRenderer(builder),
        ),
        paint: Paint()
          ..color = Colors.green
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          // Get the NodeModel from the node's key
          final nodeId = node.key?.value as String;
          // Find the NodeModel in the tree
          final nodeModel = _findNodeModelById(state.rootNode!, nodeId);
          final isSelected = state.selectedNodeId == nodeId;

          return GestureDetector(
            onTap: () {
              context.read<FlowchartCubit>().selectNode(nodeModel.id);
            },
            child: NodeWidget(
              nodeModel: nodeModel,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  void _buildGraphFromTree(NodeModel nodeModel, Node? parentNode) {
    // Create a node for the current NodeModel
    final node = Node.Id(nodeModel.id);

    // Add the node to the graph
    graph.addNode(node);

    // If there's a parent node, add an edge
    if (parentNode != null) {
      graph.addEdge(parentNode, node);
    }

    // Recursively add all challenge nodes
    for (final challenge in nodeModel.challenges) {
      _buildGraphFromTree(challenge, node);
    }
  }

  /// Find a NodeModel by its ID in the tree
  NodeModel _findNodeModelById(NodeModel rootNode, String nodeId) {
    if (rootNode.id == nodeId) {
      return rootNode;
    }

    for (final challenge in rootNode.challenges) {
      try {
        return _findNodeModelById(challenge, nodeId);
      } catch (_) {
        // Node not found in this branch, continue searching
      }
    }

    throw Exception('Node not found: $nodeId');
  }

  void _showWinnerDialog(BuildContext context) {
    final cubit = context.read<FlowchartCubit>();
    final winningNode = cubit.findWinningNode();
    final totalDonations = cubit.calculateTotalDonations();

    if (winningNode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No winner found'),
        ),
      );
      return;
    }

    // Calculate distribution
    final winnerShare = totalDonations * 0.6;
    final appShare = totalDonations * 0.2;
    final platformShare = totalDonations * 0.2;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Winning Argument'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  winningNode.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Score: ${winningNode.score} '
                  '(${winningNode.donation.toInt()} donation + '
                  '${winningNode.comments.length} comments)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Donation Distribution:'),
                const SizedBox(height: 8),
                _buildDistributionRow(
                  context,
                  'Winner (60%)',
                  winnerShare,
                ),
                _buildDistributionRow(
                  context,
                  'App Contribution (20%)',
                  appShare,
                ),
                _buildDistributionRow(
                  context,
                  'Platform Margin (20%)',
                  platformShare,
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _buildDistributionRow(
                  context,
                  'Total',
                  totalDonations,
                  isBold: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
  }) {
    final textStyle = isBold
        ? Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text('₹${amount.toStringAsFixed(2)}', style: textStyle),
        ],
      ),
    );
  }
}

/// Widget for displaying a node in the flowchart
class NodeWidget extends StatelessWidget {
  /// Constructor
  const NodeWidget({
    required this.nodeModel,
    this.isSelected = false,
    super.key,
  });

  /// Node model to display
  final NodeModel nodeModel;

  /// Whether this node is selected
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isSelected ? 8 : 1,
      color: isSelected ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nodeModel.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (nodeModel.donation > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '₹${nodeModel.donation.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
            if (nodeModel.comments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Comments:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...nodeModel.comments.map(
                (comment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(comment),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeoPopButton(
                  color: Colors.blue.shade100,
                  onTapUp: () {
                    _showCommentModal(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.comment, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Comment',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                NeoPopButton(
                  color: Colors.red.shade100,
                  onTapUp: () {
                    _showChallengeModal(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Challenge',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentModal(nodeId: nodeModel.id);
      },
    );
  }

  void _showChallengeModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ChallengeModal(parentNodeId: nodeModel.id);
      },
    );
  }
}
