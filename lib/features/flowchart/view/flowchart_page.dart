import 'package:biftech/features/donation/cubit/donation_cubit.dart';
import 'package:biftech/features/donation/view/donation_modal.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/models.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/winner/winner.dart';
import 'package:biftech/shared/animations/animations.dart';
import 'package:biftech/shared/theme/dimens.dart';
import 'package:biftech/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// TODO(graphview): Uncomment when graphview package is properly installed
// import 'package:graphview/graphview.dart';

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
  // Controller for the InteractiveViewer to programmatically control zoom/pan
  final TransformationController _transformationController =
      TransformationController();

  // Key to track the root node widget
  final GlobalKey _rootNodeKey = GlobalKey();

  // Flag to track if this is the first load of the flowchart
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
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

    // Temporary implementation until graphview package is properly installed
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 80,
              color: Colors.purple.shade300,
            ),
            const SizedBox(height: AppDimens.spaceL),
            Text(
              'Flowchart Visualization',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimens.spaceM),
            Text(
              'Graphview package integration pending',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppDimens.spaceXL),
            if (state.rootNode != null)
              NodeWidget(
                key: _rootNodeKey,
                nodeModel: state.rootNode!,
                isSelected: state.selectedNodeId == state.rootNode!.id,
              ),
          ],
        ),
      ),
    );
  }

  /// Reset the view to focus on the root node
  void _resetView() {
    final state = context.read<FlowchartCubit>().state;
    if (state.rootNode == null) return;

    // Get the root node ID
    final rootNodeId = state.rootNode!.id;

    // Select the root node to highlight it
    context.read<FlowchartCubit>().selectNode(rootNodeId);

    // Ensure the root node is visible by first resetting to identity
    // This helps prevent issues with previous transformations
    _transformationController.value = Matrix4.identity();
  }
}

/// Widget for displaying a node in the flowchart
class NodeWidget extends StatelessWidget {
  /// Constructor
  const NodeWidget({
    required this.nodeModel,
    required this.isSelected,
    super.key,
  });

  /// The node model to display
  final NodeModel nodeModel;

  /// Whether this node is currently selected
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show the node details in a modal
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => NodeDetailsModal(nodeModel: nodeModel),
        );
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purpleAccent
                  .withValues(red: 186, green: 85, blue: 211, alpha: 51)
              : Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 128),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(
            color: isSelected ? Colors.purpleAccent : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.purpleAccent
                      .withValues(red: 186, green: 85, blue: 211, alpha: 77)
                  : Colors.black
                      .withValues(red: 0, green: 0, blue: 0, alpha: 51),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nodeModel.text,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(
                        red: 255,
                        green: 255,
                        blue: 255,
                        alpha: 230,
                      ),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.spaceS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Comments count
                Row(
                  children: [
                    Icon(
                      Icons.comment,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${nodeModel.comments.length}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppDimens.spaceM),
                // Donation amount
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₹${nodeModel.donation.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
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
}

/// Modal for displaying node details
class NodeDetailsModal extends StatelessWidget {
  /// Constructor
  const NodeDetailsModal({
    required this.nodeModel,
    super.key,
  });

  /// The node model to display details for
  final NodeModel nodeModel;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimens.radiusL),
              topRight: Radius.circular(AppDimens.radiusL),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppDimens.spaceM),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Node Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Node text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(red: 0, green: 0, blue: 0, alpha: 77),
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        border: Border.all(
                          color: Colors.grey.shade800,
                        ),
                      ),
                      child: Text(
                        nodeModel.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceL),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          Icons.comment,
                          '${nodeModel.comments.length}',
                          'Comments',
                        ),
                        _buildStatItem(
                          context,
                          Icons.monetization_on,
                          '₹${nodeModel.donation.toStringAsFixed(1)}',
                          'Donations',
                        ),
                        _buildStatItem(
                          context,
                          Icons.account_tree,
                          '${nodeModel.challenges.length}',
                          'Challenges',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.spaceL),
                    // Comments section
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    // Comments list
                    if (nodeModel.comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...nodeModel.comments.map(
                        (comment) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimens.spaceM,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(
                                red: 0,
                                green: 0,
                                blue: 0,
                                alpha: 51,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusM),
                              border: Border.all(
                                color: Colors.grey.shade800,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.purpleAccent,
                                      child: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.spaceXS),
                                    Text(
                                      'User${comment.hashCode % 1000}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDate(DateTime.now()),
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.spaceXS),
                                const Text(
                                  'Sample comment text',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppDimens.spaceL),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            onPressed: () {
                              // Show donation modal
                              showModalBottomSheet<void>(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => BlocProvider(
                                  create: (context) => DonationCubit(),
                                  child: DonationModal(
                                    nodeId: nodeModel.id,
                                    onDonationComplete: (amount) {
                                      // Handle donation completion
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Donated ₹$amount successfully!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text('Donate'),
                          ),
                        ),
                        const SizedBox(width: AppDimens.spaceM),
                        Expanded(
                          child: GradientButton(
                            onPressed: () {
                              // Show challenge modal
                              // This would be implemented in a real app
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Challenge feature coming soon!',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Challenge'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.purpleAccent,
          size: 24,
        ),
        const SizedBox(height: AppDimens.spaceXS),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppDimens.spaceXXS),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
