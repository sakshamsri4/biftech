import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/flowchart/view/widgets/challenge_modal.dart';
import 'package:biftech/features/flowchart/view/widgets/comment_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/graphview.dart';

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
      ..siblingSeparation = 80
      ..levelSeparation = 120
      ..subtreeSeparation = 120
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
                    // Don't show technical error details to users
                    const Text('Something went wrong. Please try again.'),
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

    // Debug info
    debugPrint('Built graph with ${graph.nodes.length} nodes and '
        '${graph.edges.length} edges');

    // Print details about each node and edge
    for (final node in graph.nodes) {
      debugPrint('Node: ${node.key?.value}');
    }
    for (final edge in graph.edges) {
      debugPrint(
        'Edge: ${edge.source.key?.value} -> ${edge.destination.key?.value}',
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(500),
        minScale: 0.1,
        maxScale: 2,
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(
            builder,
            TreeEdgeRenderer(builder),
          ),
          paint: Paint()
            ..color = Colors.orange.shade400
            ..strokeWidth = 2
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
    // Create a map of all nodes for faster lookup
    final nodeMap = <String, NodeModel>{};
    _buildNodeMap(rootNode, nodeMap);

    // Look up the node by ID
    final node = nodeMap[nodeId];
    if (node != null) {
      return node;
    }

    // If node not found, log the error and return the root node as fallback
    debugPrint('Node not found: $nodeId, using root node as fallback');
    debugPrint('Available nodes: ${nodeMap.keys.join(', ')}');
    return rootNode;
  }

  /// Build a map of all nodes in the tree for faster lookup
  void _buildNodeMap(NodeModel node, Map<String, NodeModel> nodeMap) {
    // Add this node to the map
    nodeMap[node.id] = node;

    // Recursively add all challenge nodes
    for (final challenge in node.challenges) {
      _buildNodeMap(challenge, nodeMap);
    }
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
    // Check if this node has challenges
    final hasChallenges = nodeModel.challenges.isNotEmpty;

    // Determine the node color based on its position in the tree
    final isRoot = nodeModel.id.startsWith('root_');
    final isChallenge = nodeModel.id.startsWith('challenge_');

    return Card(
      margin: const EdgeInsets.all(4),
      elevation: isSelected ? 8 : 2,
      color: isSelected
          ? Colors.blue.shade50
          : isRoot
              ? Colors.green.shade50
              : isChallenge
                  ? Colors.orange.shade50
                  : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: hasChallenges
            ? BorderSide(color: Colors.orange.shade400, width: 2)
            : isRoot
                ? BorderSide(color: Colors.green.shade400, width: 2)
                : BorderSide.none,
      ),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 200,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isRoot)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ROOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isChallenge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'CHALLENGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              nodeModel.text,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
            if (nodeModel.comments.isNotEmpty &&
                nodeModel.comments.length <= 2) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Comments:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...nodeModel.comments.take(2).map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        comment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              if (nodeModel.comments.length > 2)
                Text(
                  '+ ${nodeModel.comments.length - 2} more comments',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, size: 16),
                      onPressed: () => _showCommentModal(context),
                      tooltip: 'Comment',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    Text(
                      '${nodeModel.comments.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.flash_on,
                        size: 16,
                        color: Colors.orange,
                      ),
                      onPressed: () => _showChallengeModal(context),
                      tooltip: 'Challenge',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    Text(
                      '${nodeModel.challenges.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentModal(BuildContext context) {
    // Get the cubit from the parent context
    final cubit = context.read<FlowchartCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentModal(
          nodeId: nodeModel.id,
          cubit: cubit,
        );
      },
    );
  }

  void _showChallengeModal(BuildContext context) {
    // Get the cubit from the parent context
    final cubit = context.read<FlowchartCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ChallengeModal(
          parentNodeId: nodeModel.id,
          cubit: cubit,
        );
      },
    );
  }
}
