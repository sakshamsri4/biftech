import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/donation/cubit/donation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

/// Modal for making a donation to a node
class DonationModal extends StatefulWidget {
  /// Constructor
  const DonationModal({
    required this.nodeId,
    required this.onDonationComplete,
    super.key,
  });

  /// ID of the node to donate to
  final String nodeId;

  /// Callback when donation is complete
  final Function(double amount) onDonationComplete;

  @override
  State<DonationModal> createState() => _DonationModalState();
}

class _DonationModalState extends State<DonationModal> {
  final _donationController = TextEditingController(text: '1.0');
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  double _donationAmount = 1.0;

  @override
  void dispose() {
    _donationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DonationCubit(),
      child: BlocConsumer<DonationCubit, DonationState>(
        listener: (context, state) {
          if (state.status == DonationStatus.success) {
            Navigator.of(context).pop();
            widget.onDonationComplete(state.amount);
          } else if (state.status == DonationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to process donation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
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
                    '💰 Make a Donation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Support this argument with a donation',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _donationAmount,
                          min: 1.0,
                          max: 100.0,
                          divisions: 99,
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
                            if (donation < 1.0) {
                              return 'Min ₹1.0';
                            }
                            if (donation > 100.0) {
                              return 'Max ₹100';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final donation = double.tryParse(value) ?? 0;
                            if (donation >= 1.0 && donation <= 100.0) {
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
                        color: Colors.green.shade100,
                        onTapUp: state.status == DonationStatus.loading
                            ? null
                            : _submitDonation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: state.status == DonationStatus.loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Donate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitDonation() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final donation = double.tryParse(_donationController.text) ?? 0;
      
      if (donation < 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Minimum donation amount is ₹1.0'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Process the donation through the cubit
      context.read<DonationCubit>().processDonation(
            nodeId: widget.nodeId,
            amount: donation,
          );
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'DonationModal._submitDonation',
      );

      if (!mounted) return;

      // Show a user-friendly message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process donation. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
