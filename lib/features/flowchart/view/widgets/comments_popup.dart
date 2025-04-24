import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/features/flowchart/model/node_model.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/theme/dimens.dart';
import 'package:flutter/material.dart';

/// A popup dialog that displays all comments for a node
class CommentsPopup extends StatelessWidget {
  /// Constructor
  const CommentsPopup({
    required this.nodeModel,
    required this.cubit,
    super.key,
  });

  /// The node model containing the comments
  final NodeModel nodeModel;

  /// The FlowchartCubit for managing flowchart state
  final FlowchartCubit cubit;

  @override
  Widget build(BuildContext context) {
    final comments = nodeModel.comments;
    final hasComments = comments.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimens.spaceM),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: secondaryBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.white.withAlpha((0.1 * 255).round()),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (hasComments)
              Flexible(
                child: _buildCommentsList(context, comments),
              )
            else
              _buildNoCommentsMessage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceXL,
        AppDimens.spaceXL,
        AppDimens.spaceXL,
        AppDimens.spaceM,
      ),
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusXL),
          topRight: Radius.circular(AppDimens.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentPrimary,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    child: const Icon(
                      Icons.comment,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentPrimary,
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                ),
                child: Text(
                  '${nodeModel.comments.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            decoration: BoxDecoration(
              color: primaryBackground,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(
                color: Colors.white.withAlpha((0.1 * 255).round()),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discussion Point',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textWhite50,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  nodeModel.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, List<String> comments) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceXL),
      shrinkWrap: true,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isEven = index.isEven;

        return Container(
          margin: const EdgeInsets.only(bottom: AppDimens.spaceM),
          padding: const EdgeInsets.all(AppDimens.spaceM),
          decoration: BoxDecoration(
            color: isEven ? secondaryBackground : primaryBackground,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(
              color: Colors.white.withAlpha((0.1 * 255).round()),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getAvatarColor(index),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(index),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUsername(index),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        _getTimeAgo(index),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: textWhite50,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comment,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoCommentsMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceXL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: textWhite50,
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textWhite70,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textWhite50,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to generate mock user data
  String _getUsername(int index) {
    final usernames = [
      'Alex',
      'Taylor',
      'Jordan',
      'Casey',
      'Morgan',
      'Riley',
      'Avery',
      'Quinn',
    ];
    return usernames[index % usernames.length];
  }

  String _getInitials(int index) {
    final username = _getUsername(index);
    return username.substring(0, 1).toUpperCase();
  }

  String _getTimeAgo(int index) {
    final times = [
      'Just now',
      '5 min ago',
      '10 min ago',
      '30 min ago',
      '1 hour ago',
      '2 hours ago',
      'Yesterday',
      '2 days ago',
    ];
    return times[index % times.length];
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue.shade800,
      Colors.purple.shade800,
      Colors.green.shade800,
      Colors.orange.shade800,
      Colors.pink.shade800,
      Colors.teal.shade800,
      Colors.indigo.shade800,
      Colors.amber.shade800,
    ];
    return colors[index % colors.length];
  }
}
