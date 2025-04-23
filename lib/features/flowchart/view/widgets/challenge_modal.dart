import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/flowchart/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _donationController = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  double _donationAmount = 0;

  @override
  void dispose() {
    _textController.dispose();
    _donationController.dispose();
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
            Text(
              'Donation (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _donationAmount,
                    max: 100,
                    divisions: 20,
                    label: '₹${_donationAmount.toStringAsFixed(1)}',
                    onChanged: (value) {
                      setState(() {
                        _donationAmount = value;
                        _donationController.text = value.toStringAsFixed(1);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _donationController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}$'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final donation = double.tryParse(value);
                      if (donation == null) {
                        return 'Invalid';
                      }
                      if (donation < 0) {
                        return 'Min 0';
                      }
                      if (donation > 100) {
                        return 'Max 100';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final donation = double.tryParse(value) ?? 0;
                      if (donation >= 0 && donation <= 100) {
                        setState(() {
                          _donationAmount = donation;
                        });
                      }
                    },
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
      final donation = double.tryParse(_donationController.text) ?? 0;

      await widget.cubit.addChallenge(
        widget.parentNodeId,
        _textController.text.trim(),
        donation,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
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
}
