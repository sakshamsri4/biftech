import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/theme/dimens.dart';
import 'package:biftech/shared/widgets/buttons/primary_button.dart';
import 'package:biftech/shared/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal for adding a comment to a node
class CommentModal extends StatefulWidget {
  /// Constructor
  const CommentModal({
    required this.nodeId,
    required this.cubit,
    super.key,
  });

  /// ID of the node to comment on
  final String nodeId;

  /// Cubit for managing flowchart state
  final FlowchartCubit cubit;

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppDimens.spaceM,
        left: AppDimens.spaceM,
        right: AppDimens.spaceM,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.spaceM,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💬 Add Comment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textWhite,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppDimens.spaceM),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Your Comment',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  borderSide: const BorderSide(color: textWhite50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  borderSide: const BorderSide(color: accentPrimary),
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a comment';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimens.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: AppDimens.spaceXS),
                PrimaryButton(
                  label: 'Submit',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          _submitComment();
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.cubit.addComment(
        widget.nodeId,
        _commentController.text.trim(),
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      Navigator.of(context).pop();

      // Notify any listeners that a comment was added
      // This will help update the donation page
      widget.cubit.notifyCommentAdded();
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'CommentModal._submitComment',
      );

      if (!mounted) return;

      // Show a user-friendly message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add comment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
