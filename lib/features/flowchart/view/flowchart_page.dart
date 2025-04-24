import 'package:biftech/features/donation/cubit/donation_cubit.dart';
import 'package:biftech/features/donation/view/donation_modal.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/flowchart/view/widgets/widgets.dart';
import 'package:biftech/features/winner/winner.dart';
import 'package:biftech/shared/animations/animations.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/theme/dimens.dart';
import 'package:biftech/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // Apply dark background globally here
      child: const ColoredBox(
        color: Color(0xFF1A1A2E), // Base dark color
        child: FlowchartView(),
      ),
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
      backgroundColor: Colors.transparent, // Make scaffold transparent
      appBar: AppBar(
        title: const Text(
          'Discussion Flowchart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        actions: [
          // Refresh button with animation and haptics
          PressableScale(
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              tooltip: 'Reload & Recenter',
              onPressed: () {
                HapticFeedback.lightImpact();
                _transformationController.value = Matrix4.identity();
                context.read<FlowchartCubit>().loadFlowchart();
                Future<void>.delayed(
                  const Duration(milliseconds: 800),
                  () {
                    if (mounted) {
                      setState(() {});
                      _resetView();
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
          ),
          // Declare winner button with animation and haptics
          PressableScale(
            child: IconButton(
              icon: const Icon(
                Icons.workspace_premium,
                color: Colors.purpleAccent,
              ), // Purple accent
              tooltip: 'Declare winner',
              onPressed: () {
                HapticFeedback.lightImpact();
                final flowchartCubit = context.read<FlowchartCubit>();
                final videoId = flowchartCubit.videoId;
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
          ),
        ],
      ),
      body: BlocBuilder<FlowchartCubit, FlowchartState>(
        builder: (context, state) {
          switch (state.status) {
            case FlowchartStatus.initial:
            case FlowchartStatus.loading:
              // Custom Loading State
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purpleAccent,
                      ),
                    ),
                    SizedBox(height: AppDimens.spaceL),
                    Text(
                      'Loading Flowchart...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              );
            case FlowchartStatus.failure:
              // Custom Error State
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: AppDimens.spaceM),
                      Text(
                        'Oops! Failed to load flowchart.',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.spaceXS),
                      Text(
                        'Something went wrong. '
                        'Please check your connection and try again.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.spaceXL),
                      // Use GradientButton for retry
                      GradientButton(
                        onPressed: () {
                          context.read<FlowchartCubit>().loadFlowchart();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            case FlowchartStatus.success:
              if (state.rootNode == null) {
                // Custom Empty State
                // (if flowchart is successfully loaded but empty)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_tree_outlined,
                          size: 80,
                          color: Colors.purple.shade200,
                        ),
                        const SizedBox(height: AppDimens.spaceL),
                        Text(
                          'Discussion Not Started',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Be the first to add a point to this video's "
                          'discussion!',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
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
            ..color = Colors.purpleAccent.withAlpha((0.5 * 255).round())
            ..strokeWidth = 1.5
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
                HapticFeedback.lightImpact();
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
              SnackBar(
                content: const Text('View recentered'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.grey.shade800, // Dark snackbar
                behavior: SnackBarBehavior.floating, // Optional: floating style
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
    // Theme elements
    const signaturePurple = Colors.deepPurpleAccent; // Adjusted purple
    const cardDarkBg = Color(0xFF2A2A3E); // Slightly lighter dark for card
    const borderRadius = BorderRadius.all(Radius.circular(AppDimens.radiusXL));
    final shadowColor = Colors.black.withAlpha((0.4 * 255).round());
    const shadowBlurRadius = AppDimens.spaceS;
    const shadowOffset = Offset(0, 6);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.3,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withAlpha((0.85 * 255).round()),
          height: 1.4,
        );
    final smallTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withAlpha((0.7 * 255).round()),
        );

    // Determine node type
    final isRoot = nodeModel.id.startsWith('root_');
    // final isChallenge = nodeModel.id.startsWith('challenge_');

    // Define border based on selection
    final border = isSelected
        ? Border.all(color: signaturePurple, width: 2.5)
        : Border.all(color: Colors.white.withAlpha((0.15 * 255).round()));

    return Container(
      margin: const EdgeInsets.all(10),
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 240,
      ),
      decoration: BoxDecoration(
        color: cardDarkBg,
        borderRadius: borderRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Root node indicator
            if (isRoot)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.spaceXS),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade300,
                      size: AppDimens.spaceM,
                    ),
                    const SizedBox(width: AppDimens.spaceXXS),
                    Text(
                      'Starting Point',
                      style: smallTextStyle?.copyWith(
                        color: Colors.amber.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Node Text (Title)
            Text(nodeModel.text, style: titleStyle),

            // Donation Info
            // - Always show, but with different styling based on amount
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: nodeModel.donation > 0
                      ? Colors.greenAccent.shade400
                      : const Color.fromARGB(128, 128, 128, 128),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  nodeModel.donation > 0
                      ? '₹${nodeModel.donation.toStringAsFixed(0)}'
                      : 'No donations yet',
                  style: bodyStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: nodeModel.donation > 0
                        ? Colors.greenAccent.shade400
                        : const Color.fromARGB(128, 128, 128, 128),
                  ),
                ),
              ],
            ),

            // Comments Section (if any)
            if (nodeModel.comments.isNotEmpty) ...[
              const SizedBox(height: AppDimens.spaceS),
              Divider(color: Colors.white.withAlpha((0.1 * 255).round())),
              const SizedBox(height: AppDimens.spaceXS),
              InkWell(
                // Make the whole comment section tappable
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showCommentsPopup(context);
                },
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimens.spaceXXS),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        color: Colors.white70,
                        size: AppDimens.spaceM,
                      ),
                      const SizedBox(width: AppDimens.spaceXS),
                      Expanded(
                        child: Text(
                          nodeModel.comments.first,
                          style: smallTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimens.spaceXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: signaturePurple.withAlpha((0.8 * 255).round()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${nodeModel.comments.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Action Buttons Divider (always show for spacing)
            const SizedBox(height: AppDimens.spaceXS),
            Divider(color: Colors.white.withAlpha((0.1 * 255).round())),
            const SizedBox(height: AppDimens.spaceXXS),

            // Action Buttons (Comment/Donate/Challenge)
            Row(
              // Use spaceBetween for better control and wrap buttons with
              // Flexible
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Comment Button - Wrap with Flexible
                Flexible(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.add_comment_outlined,
                    label: 'Comment',
                    onPressed: () => _showCommentModal(context),
                    color: Colors.white70,
                  ),
                ),
                // Donate Button - Wrap with Flexible
                Flexible(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.monetization_on_outlined,
                    label: 'Donate',
                    onPressed: () => _showDonationModal(context),
                    color: Colors.greenAccent.shade400,
                  ),
                ),
                // Challenge Button - Wrap with Flexible
                Flexible(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.flash_on_outlined,
                    label: 'Challenge',
                    onPressed: () => _showChallengeModal(context),
                    color: Colors.purpleAccent, // Use purple accent
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for action buttons (redesigned)
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        // Reduce horizontal padding further
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXXL),
        ),
        // Allow button to shrink
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
        // Prevent wrapping and use ellipsis if text is too long
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
    );
  }

  // --- Modal Launchers --- (Add Haptic Feedback & Dark Theme Styling)

  void _showCommentsPopup(BuildContext context) {
    final cubit = context.read<FlowchartCubit>();
    showDialog<void>(
      context: context,
      // Use a custom barrier color for dark theme
      barrierColor: Colors.black.withAlpha((0.7 * 255).round()),
      builder: (dialogContext) {
        return CommentsPopup(
          nodeModel: nodeModel,
          cubit: cubit,
          onAddCommentPressed: () {
            // Show the comment modal after the popup is closed
            // Use a slight delay to ensure the popup is fully closed
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                _showCommentModal(context);
              }
            });
          },
        );
      },
    );
  }

  void _showCommentModal(BuildContext context) {
    // Store the FlowchartCubit before showing the modal
    final flowchartCubit = context.read<FlowchartCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: secondaryBackground, // Use theme color
      barrierColor: Colors.black.withAlpha((0.7 * 255).round()),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXXL)),
      ),
      builder: (modalContext) {
        // Provide cubit to the modal using BlocProvider.value
        return BlocProvider<FlowchartCubit>.value(
          value: flowchartCubit,
          child: Builder(
            builder: (providerContext) {
              // Use the new context that has access to the provider
              return CommentModal(
                nodeId: nodeModel.id,
                cubit: flowchartCubit,
              );
            },
          ),
        );
      },
    );
  }

  void _showChallengeModal(BuildContext context) {
    // Store the FlowchartCubit before showing the modal
    final flowchartCubit = context.read<FlowchartCubit>();

    // Update ChallengeModal design for dark theme
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: secondaryBackground, // Use theme color
      barrierColor: Colors.black.withAlpha((0.7 * 255).round()),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXXL)),
      ),
      builder: (modalContext) {
        // Provide cubit to the modal using BlocProvider.value
        return BlocProvider<FlowchartCubit>.value(
          value: flowchartCubit,
          child: Builder(
            builder: (providerContext) {
              // Use the new context that has access to the provider
              return ChallengeModal(
                parentNodeId: nodeModel.id,
                cubit: flowchartCubit,
              );
            },
          ),
        );
      },
    );
  }

  void _showDonationModal(BuildContext context) {
    // Store the FlowchartCubit before showing the modal
    // This ensures we're getting it from the correct context
    final flowchartCubit = context.read<FlowchartCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: secondaryBackground,
      barrierColor: Colors.black.withAlpha((0.7 * 255).round()),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXXL)),
      ),
      builder: (modalContext) {
        // Create a MultiBlocProvider to provide both cubits
        return MultiBlocProvider(
          providers: [
            // Provide the existing FlowchartCubit using BlocProvider.value
            BlocProvider<FlowchartCubit>.value(
              value: flowchartCubit,
            ),
            // Create a new DonationCubit with the FlowchartCubit
            BlocProvider<DonationCubit>(
              create: (context) =>
                  DonationCubit(flowchartCubit: flowchartCubit),
            ),
          ],
          child: Builder(
            builder: (providerContext) {
              // Use the new context that has access to both providers
              return DonationModal(
                nodeId: nodeModel.id,
                nodeText: nodeModel.text,
                currentDonation: nodeModel.donation,
                onDonationComplete: (double amount) {
                  // The donation is handled by the DonationCubit
                  // which will update the FlowchartCubit
                  Navigator.of(modalContext).pop();

                  // Show a success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Donation of ₹$amount successful!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
