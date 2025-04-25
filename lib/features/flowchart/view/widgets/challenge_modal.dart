import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/donation/cubit/donation_cubit.dart';
import 'package:biftech/features/donation/view/donation_modal.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/theme/dimens.dart';
import 'package:biftech/shared/widgets/buttons/primary_button.dart';
import 'package:biftech/shared/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define CRED styles with dark theme
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: textWhite,
          fontWeight: FontWeight.w700,
        );
    const labelStyle = TextStyle(color: textWhite70);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      borderSide: const BorderSide(color: textWhite50),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: AppDimens.spaceM,
        left: AppDimens.spaceM,
        right: AppDimens.spaceM,
        // Adjust padding to prevent keyboard overlap
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.spaceM,
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
            const SizedBox(height: AppDimens.spaceM),
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Your Argument / Counter-Point',
                labelStyle: labelStyle,
                hintText: 'Present your counter-argument...',
                hintStyle: const TextStyle(color: textWhite50),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  borderSide: const BorderSide(color: accentPrimary),
                ),
                filled: true,
                fillColor: primaryBackground,
              ),
              maxLines: 4, // Allow more lines for detailed arguments
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textWhite, // Explicitly set text color to white
                  ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your argument';
                }
                if (value.trim().length < 10) {
                  // Encourage more thoughtful challenges
                  return 'Argument should be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimens.spaceL), // Increased spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                ),
                const SizedBox(width: AppDimens.spaceXS), // Spacing
                // Submit Button
                PrimaryButton(
                  label: 'Next: Add Donation',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _proceedToDonation,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Proceed to donation screen after validating challenge
  Future<void> _proceedToDonation() async {
    // Validate the form
    if (_formKey.currentState?.validate() != true) {
      await HapticFeedback.heavyImpact(); // Indicate validation error
      return;
    }

    // Store the challenge text temporarily
    final challengeText = _textController.text.trim();

    // Close the current modal
    if (!mounted) return;
    Navigator.of(context).pop();

    // Store the FlowchartCubit before showing the modal
    // This is the key fix - we're getting the cubit from the current context
    // where it's definitely available
    final flowchartCubit = widget.cubit;

    // Show the donation modal
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: secondaryBackground,
      barrierColor: Colors.black.withAlpha((0.7 * 255).round()),
      builder: (BuildContext modalContext) {
        // Use MultiBlocProvider to provide both cubits
        return MultiBlocProvider(
          providers: [
            // Provide the existing FlowchartCubit
            BlocProvider<FlowchartCubit>.value(
              value: flowchartCubit,
            ),
            // Create a new DonationCubit
            BlocProvider<DonationCubit>(
              create: (_) => DonationCubit(flowchartCubit: flowchartCubit),
            ),
          ],
          child: Builder(
            builder: (providerContext) {
              // Use the new context that has access to both providers
              return DonationModal(
                nodeId: widget.parentNodeId,
                nodeText: 'Support your challenge with a donation',
                onDonationComplete: (double amount) async {
                  // Now submit the challenge with the donation amount
                  await _submitChallenge(challengeText, amount);
                },
              );
            },
          ),
        );
      },
    );
  }

  // Submit challenge with donation amount
  Future<void> _submitChallenge(
    String challengeText,
    double donationAmount,
  ) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Adding your challenge...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      // Log the challenge submission
      debugPrint(
        'Submitting challenge to node ${widget.parentNodeId}: '
        '"$challengeText" with donation: $donationAmount',
      );

      // Call the cubit to add the challenge
      final newNodeId = await widget.cubit.addChallenge(
        widget.parentNodeId,
        challengeText,
        donationAmount,
      );

      // Log the result
      debugPrint('Challenge added successfully with ID: $newNodeId');

      if (!mounted) return;

      // Clear any existing snackbars
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Challenge added with ₹$donationAmount donation!',
          ),
          backgroundColor: success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Force a reload of the flowchart to ensure the UI updates
      // This is critical to see the new node
      if (mounted) {
        // Wait a moment for the state to update
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Force reload the flowchart
        if (mounted) {
          debugPrint('Forcing flowchart reload to show new node');
          await widget.cubit.loadFlowchart();
        }
      }
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'ChallengeModal._submitChallenge',
      );

      if (!mounted) return;

      // Clear any existing snackbars
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to add challenge. Please try again.',
          ),
          backgroundColor: error,
        ),
      );
    }
  }
}
