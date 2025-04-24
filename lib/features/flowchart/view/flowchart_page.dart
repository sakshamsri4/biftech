import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/flowchart/view/widgets/widgets.dart';
import 'package:biftech/features/winner/winner.dart';
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
      create: (context) {
        final cubit = FlowchartCubit(
          repository: FlowchartRepository.instance,
          videoId: videoId,
        );

        // Load the flowchart and ensure the root node is selected
        cubit.loadFlowchart().then((_) {
          if (cubit.state.rootNode != null) {
            // Select the root node to ensure it's highlighted
            cubit.selectNode(cubit.state.rootNode!.id);

            // Select it again after a delay to ensure it's still selected
            // after any state changes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (cubit.state.rootNode != null) {
                cubit.selectNode(cubit.state.rootNode!.id);
              }
            });
          }
        });

        return cubit;
      },
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

  // Controller for the InteractiveViewer to programmatically control zoom/pan
  final TransformationController _transformationController =
      TransformationController();

  // Key for the InteractiveViewer to force rebuild when needed
  final GlobalKey _graphKey = GlobalKey();

  // Key to track the root node widget
  final GlobalKey _rootNodeKey = GlobalKey();

  // Flag to track if this is the first load of the flowchart
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Configure the layout algorithm
    builder
      ..siblingSeparation = 100
      ..levelSeparation = 150
      ..subtreeSeparation = 150
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    // Add a listener to focus on the root node when the flowchart is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Initial reset view when the widget is first built
        _resetView();

        // Apply a second reset after a delay to ensure the graph is fully built
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _resetView();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Flowchart'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload flowchart and focus on root node',
            onPressed: () {
              // First reset the view to
              // ensure we're starting from a clean state
              // by resetting the transformation
              _transformationController.value = Matrix4.identity();

              // Then reload the flowchart
              context.read<FlowchartCubit>().loadFlowchart();

              // Reset view after a longer delay to ensure the flowchart
              // is fully loaded and rendered
              Future<void>.delayed(
                const Duration(milliseconds: 800),
                () {
                  if (mounted) {
                    // Force a rebuild of the graph
                    setState(() {});

                    // Then reset the view to focus on the root node
                    _resetView();

                    // Apply a second reset after a delay as a backup
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        _resetView();
                      }
                    });
                  }
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.workspace_premium),
            tooltip: 'Declare winner',
            onPressed: () {
              // Get the FlowchartCubit and videoId
              final flowchartCubit = context.read<FlowchartCubit>();
              final videoId = flowchartCubit.videoId;

              // Navigate to the WinnerPage with the FlowchartCubit
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => WinnerPage(
                    videoId: videoId,
                    flowchartCubit: flowchartCubit,
                  ),
                ),
              );
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

    // Debug the selected node
    if (state.selectedNodeId != null) {
      debugPrint('Selected node: ${state.selectedNodeId}');
    }

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

    // If this is the first load, ensure we focus on the root node
    // after the graph is built
    if (_isFirstLoad) {
      _isFirstLoad = false;
      // Use a post-frame callback to ensure the graph is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Use a longer delay for the initial focus
          // to ensure the graph is fully built
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              _resetView();

              // Apply a second reset after a short delay as a backup
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _resetView();
                }
              });
            }
          });
        }
      });
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InteractiveViewer(
        key: _graphKey,
        transformationController: _transformationController,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.1,
        maxScale: 2,
        onInteractionEnd: (details) {
          // Debug the current transformation
          final matrix = _transformationController.value;
          debugPrint('Current transformation matrix: $matrix');

          // Log the scale factor (useful for debugging zoom issues)
          final scale = matrix.getMaxScaleOnAxis();
          debugPrint('Current scale factor: $scale');

          // Log translation values (useful for debugging position issues)
          final translationX = matrix.getTranslation().x;
          final translationY = matrix.getTranslation().y;
          debugPrint('Current translation: ($translationX, $translationY)');
        },
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
            final isRootNode = nodeModel.id == state.rootNode!.id;

            // Use the root node key for the root node
            final key = isRootNode ? _rootNodeKey : null;

            return GestureDetector(
              onTap: () {
                context.read<FlowchartCubit>().selectNode(nodeModel.id);
              },
              child: NodeWidget(
                key: key,
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

  /// Reset the view to focus on the root node
  void _resetView() {
    final state = context.read<FlowchartCubit>().state;
    if (state.rootNode == null) return;

    // Get the root node ID
    final rootNodeId = state.rootNode!.id;

    // Select the root node to highlight it
    context.read<FlowchartCubit>().selectNode(rootNodeId);

    // Force a rebuild of the graph
    setState(() {
      // Clear and rebuild the graph
      graph.nodes.clear();
      graph.edges.clear();
      _buildGraphFromTree(state.rootNode!, null);
    });

    // Ensure the root node is visible by first resetting to identity
    // This helps prevent issues with previous transformations
    _transformationController.value = Matrix4.identity();

    // Use a longer delay to ensure the graph is fully built and laid out
    // This is critical for reliable focusing on the first node
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      try {
        // Find the actual position of the root node using its key
        final rootNodeBox =
            _rootNodeKey.currentContext?.findRenderObject() as RenderBox?;

        if (rootNodeBox != null) {
          // Get the position of the root node in the global coordinate system
          final rootNodePosition = rootNodeBox.localToGlobal(Offset.zero);

          // Get the size of the root node
          final rootNodeSize = rootNodeBox.size;

          // Get the container size
          final containerWidth = MediaQuery.of(context).size.width;
          final containerHeight = MediaQuery.of(context).size.height * 0.8;

          // Calculate the center of the container
          final containerCenterX = containerWidth / 2;
          final containerCenterY = containerHeight / 2;

          // Calculate the offset needed to center the root node
          final offsetX =
              containerCenterX - rootNodePosition.dx - (rootNodeSize.width / 2);
          final offsetY = containerCenterY -
              rootNodePosition.dy -
              (rootNodeSize.height / 2);

          // Create a transformation matrix that centers the root node
          final matrix = Matrix4.identity()..translate(offsetX, offsetY);

          // Apply the transformation
          _transformationController.value = matrix;

          // Debug print to help diagnose issues
          debugPrint('Reset view to focus on root node: $rootNodeId');
          debugPrint(
            'Root node position: $rootNodePosition, size: $rootNodeSize',
          );
          debugPrint(
            'Container center: ($containerCenterX, $containerCenterY)',
          );
          debugPrint('Applied offset: ($offsetX, $offsetY)');
          debugPrint('Applied transformation: $matrix');

          // Show a snackbar to provide feedback to the user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View reset to root node'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          debugPrint('Root node not found in render tree, using fallback');
          // Fallback if the root node is not found
          final containerWidth = MediaQuery.of(context).size.width;
          final matrix = Matrix4.identity()..translate(containerWidth / 2, 100);
          _transformationController.value = matrix;
        }
      } catch (e) {
        debugPrint('Error resetting view: $e');
        // Try again with a longer delay if there was an error
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Fallback to a simpler transformation
              // if the first attempt failed
              final matrix = Matrix4.identity()..translate(100.0, 100);
              _transformationController.value = matrix;
            }
          });
        }
      }
    });
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
    // CRED Design Principles
    const signaturePurple = Color(0xFF6C63FF);
    const borderRadius = BorderRadius.all(Radius.circular(16)); // 16px radius
    final shadowColor = Colors.black.withOpacity(0.3); // 30% opacity shadow
    const shadowBlurRadius = 8.0; // 8px blur
    const shadowOffset = Offset(0, 4); // Offset for depth
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, // Bold (700 weight)
          fontSize: 18, // 18pt
          color: Colors.white, // High contrast
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.85), // High contrast
        );
    final smallTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withOpacity(0.7), // High contrast
        );
    // Removed subtleBorderStyle as border is handled directly in BoxDecoration

    // Determine node type and colors
    final isRoot = nodeModel.id.startsWith('root_');
    final isChallenge = nodeModel.id.startsWith('challenge_');

    // Define gradient based on node type and selection
    final Gradient nodeGradient;
    if (isSelected) {
      nodeGradient = LinearGradient(
        colors: [signaturePurple.withOpacity(0.9), signaturePurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isRoot) {
      nodeGradient = LinearGradient(
        colors: [Colors.green.shade700, Colors.green.shade900],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isChallenge) {
      nodeGradient = LinearGradient(
        colors: [Colors.orange.shade700, Colors.orange.shade900],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Default gradient for other nodes (if any)
      nodeGradient = LinearGradient(
        colors: [Colors.grey.shade700, Colors.grey.shade900],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Container(
      margin: const EdgeInsets.all(8), // Add margin for shadow visibility
      constraints: const BoxConstraints(
        minWidth: 150, // Adjusted min width
        maxWidth: 220, // Adjusted max width
      ),
      decoration: BoxDecoration(
        gradient: nodeGradient,
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.5) // Brighter border when selected
              : Colors.white.withOpacity(0.1), // Subtle border
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Material(
        // Use Material for InkWell effect if needed later
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          // Optional: Add InkWell for tap feedback
          borderRadius: borderRadius,
          onTap: () {
            context.read<FlowchartCubit>().selectNode(nodeModel.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16), // Increased padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Node Text (Title)
                Text(
                  nodeModel.text,
                  style: titleStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Donation Info
                if (nodeModel.donation > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber.shade300,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${nodeModel.donation.toStringAsFixed(2)}',
                        // Add null check for bodyStyle
                        style: bodyStyle?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade300,
                        ),
                      ),
                    ],
                  ),
                ],

                // Comments Section
                if (nodeModel.comments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showCommentsPopup(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments', // Simplified label
                          // Add null check for smallTextStyle
                          style: smallTextStyle?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '${nodeModel.comments.length}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display first comment preview
                  GestureDetector(
                    onTap: () => _showCommentsPopup(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nodeModel.comments.first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: smallTextStyle, // Keep original style here
                          ),
                          if (nodeModel.comments.length > 1) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Tap to view all ${nodeModel.comments.length}',
                              style: TextStyle(
                                color: signaturePurple.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                // Action Buttons (Comment/Challenge)
                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.15)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Comment Button
                    _buildActionButton(
                      context: context,
                      icon: Icons.comment_outlined, // Use outlined icon
                      count: nodeModel.comments.length,
                      tooltip: 'Comment',
                      onPressed: () => _showCommentModal(context),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    // Challenge Button
                    _buildActionButton(
                      context: context,
                      icon: Icons.flash_on_outlined, // Use outlined icon
                      count: nodeModel.challenges.length,
                      tooltip: 'Challenge',
                      onPressed: () => _showChallengeModal(context),
                      color: Colors.orange.shade300, // Accent color
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for action buttons
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required int count,
    required String tooltip,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero, // Remove default min size
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap area
        foregroundColor: color, // Icon and text color
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        '$count',
        // Add null check for textTheme.bodySmall
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.bold, color: color),
      ),
      onPressed: onPressed,
      // tooltip: tooltip, // Tooltip might be redundant on mobile
    );
  }

  void _showCommentsPopup(BuildContext context) {
    // Get the cubit from the parent context
    final cubit = context.read<FlowchartCubit>();

    showDialog<void>(
      context: context,
      builder: (context) {
        // TODO: Update CommentsPopup with CRED style
        return CommentsPopup(
          nodeModel: nodeModel,
          cubit: cubit,
        );
      },
    );
  }

  void _showCommentModal(BuildContext context) {
    // Get the cubit from the parent context
    final cubit = context.read<FlowchartCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900, // Dark background for modal
      shape: const RoundedRectangleBorder(
        // Consistent rounded corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // TODO: Update CommentModal with CRED style
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
      backgroundColor: Colors.grey.shade900, // Dark background for modal
      shape: const RoundedRectangleBorder(
        // Consistent rounded corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // ChallengeModal already updated
        return ChallengeModal(
          parentNodeId: nodeModel.id,
          cubit: cubit,
        );
      },
    );
  }
}
