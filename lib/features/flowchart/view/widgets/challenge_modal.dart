import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/donation/donation.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

/// Modal for adding a challenge to a node
class ChallengeModal extends StatefulWidget {
  /// Constructor
  const ChallengeModal({
    required this.parentNodeId,
    required this.cubit,
    super.key,
  });

  /// ID of the parent node to challenge
  final String parentNodeId;

  /// Cubit for managing flowchart state
  final FlowchartCubit cubit;

  @override
  State<ChallengeModal> createState() => _ChallengeModalState();
}

class _ChallengeModalState extends State<ChallengeModal> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _showDonationAfterSubmit = false;
  // We don't need to store the challenge node ID as a field

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚔️ Challenge',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Your Argument',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your argument';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _showDonationAfterSubmit,
                  onChanged: (value) {
                    setState(() {
                      _showDonationAfterSubmit = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Add a donation to strengthen your challenge',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeoPopButton(
                  color: Colors.grey.shade200,
                  onTapUp: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                NeoPopButton(
                  color: Colors.red.shade100,
                  onTapUp: _isSubmitting ? null : _submitChallenge,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit Challenge'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitChallenge() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // First add the challenge with 0 donation
      final challengeNodeId = await widget.cubit.addChallenge(
        widget.parentNodeId,
        _textController.text.trim(),
        0, // Initial donation amount is 0
      );

      if (!mounted) return;

      // We have the challenge node ID from the cubit

      // Close the challenge modal
      Navigator.of(context).pop();

      // If user wants to add a donation, show the donation modal
      if (_showDonationAfterSubmit && mounted) {
        _showDonationModal(context, challengeNodeId);
      }
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'ChallengeModal._submitChallenge',
      );

      if (!mounted) return;

      // Show a user-friendly message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add challenge. Please try again.'),
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

  void _showDonationModal(BuildContext context, String nodeId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DonationModal(
          nodeId: nodeId,
          onDonationComplete: (amount) {
            // Update the node with the donation amount
            widget.cubit.updateNodeDonation(nodeId, amount);
          },
        );
      },
    );
  }
}
