import 'package:biftech/features/flowchart/model/models.dart';
import 'package:equatable/equatable.dart';

/// Status of the flowchart
enum FlowchartStatus {
  /// Initial state
  initial,

  /// Loading data
  loading,

  /// Successfully loaded data
  success,

  /// Failed to load data
  failure,
}

/// State for the flowchart
class FlowchartState extends Equatable {
  /// Constructor
  const FlowchartState({
    this.status = FlowchartStatus.initial,
    this.rootNode,
    this.expandedNodeIds = const {},
    this.selectedNodeId,
    this.error,
  });

  /// Initial state
  static const initial = FlowchartState();

  /// Status of the flowchart
  final FlowchartStatus status;

  /// Root node of the flowchart
  final NodeModel? rootNode;

  /// Set of expanded node IDs
  final Set<String> expandedNodeIds;

  /// Currently selected node ID
  final String? selectedNodeId;

  /// Error message if status is failure
  final String? error;

  /// Create a copy of this state with the given fields replaced
  FlowchartState copyWith({
    FlowchartStatus? status,
    NodeModel? rootNode,
    Set<String>? expandedNodeIds,
    String? selectedNodeId,
    String? error,
  }) {
    return FlowchartState(
      status: status ?? this.status,
      rootNode: rootNode ?? this.rootNode,
      expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rootNode,
        expandedNodeIds,
        selectedNodeId,
        error,
      ];
}
