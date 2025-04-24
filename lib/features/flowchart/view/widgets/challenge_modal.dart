import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define CRED styles
    const signaturePurple = Color(0xFF6C63FF);
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87);
    final labelStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Slightly rounded corners
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        // Adjust padding to prevent keyboard overlap
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make modal height fit content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚔️ Add Challenge', // Updated title
              style: titleStyle,
            ),
            const SizedBox(height: 24), // Increased spacing
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Your Argument / Counter-Point', // More descriptive
                labelStyle: labelStyle,
                border: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide:
                      const BorderSide(color: signaturePurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50, // Subtle background
              ),
              maxLines: 4, // Allow more lines for detailed arguments
              style:
                  const TextStyle(color: Colors.black87), // High contrast text
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your argument';
                  // Clearer validation message
                }
                if (value.trim().length < 10) {
                  // Encourage more thoughtful challenges
                  return 'Argument should be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24), // Increased spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                NeoPopButton(
                  color: Colors.grey.shade300, // Neutral color
                  onTapUp: _isSubmitting
                      ? null
                      : Navigator.of(context).pop, // Use tearoff
                  onTapDown: HapticFeedback.lightImpact, // Use tearoff
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, // More padding
                      vertical: 12,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600, // Bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Spacing
                // Submit Button
                NeoPopButton(
                  color: signaturePurple, // Signature color
                  onTapUp: _isSubmitting ? null : _submitChallenge,
                  onTapDown: HapticFeedback.mediumImpact, // Use tearoff
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, // More padding
                      vertical: 12,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, // Consistent size
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Challenge',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold, // Bold
                            ),
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

  Future<void> _submitChallenge() async {
    // Validate the form
    if (_formKey.currentState?.validate() != true) {
      await HapticFeedback.heavyImpact(); // Indicate validation error (await)
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // For now, let's assume a default donation or handle it later
      const donationAmount = 0.0; // Placeholder

      // Call the cubit to add the challenge
      await widget.cubit.addChallenge(
        widget.parentNodeId,
        _textController.text.trim(),
        donationAmount, // Pass donation amount
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Close the modal
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'ChallengeModal._submitChallenge',
      );

      if (!mounted) return;

      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add challenge: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Ensure state is updated even
      //if widget is disposed during async operation
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
