import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/donation/cubit/donation_cubit.dart';
import 'package:biftech/features/donation/cubit/donation_state.dart';
import 'package:biftech/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal for making a donation to a node (CRED Style)
class DonationModal extends StatefulWidget {
  /// Constructor
  const DonationModal({
    required this.onDonationComplete,
    this.nodeId = '',
    this.nodeText = 'Support this argument with a donation',
    this.currentDonation = 0.0,
    super.key,
  });

  /// ID of the node to donate to
  final String nodeId;

  /// Text of the node being donated to
  final String nodeText;

  /// Current donation amount on the node
  final double currentDonation;

  /// Callback when donation is complete
  final void Function(double amount) onDonationComplete;

  @override
  State<DonationModal> createState() => _DonationModalState();
}

class _DonationModalState extends State<DonationModal> {
  String _amountString = '10'; // Default amount
  final List<String> _quickAmounts = ['10', '25', '50', '100'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'DEL') {
        if (_amountString.isNotEmpty) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
          if (_amountString.isEmpty) _amountString = '0';
        }
      } else if (key == '.') {
        if (!_amountString.contains('.')) {
          _amountString += key;
        }
      } else {
        if (_amountString == '0') {
          _amountString = key;
        } else {
          if (_amountString.length < 6) {
            if (_amountString.contains('.') &&
                _amountString.split('.').last.isNotEmpty) {
            } else {
              _amountString += key;
            }
          }
        }
      }
      if (_amountString == '.') _amountString = '0.';
    });
  }

  void _selectQuickAmount(String amount) {
    HapticFeedback.mediumImpact();
    setState(() {
      _amountString = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DonationCubit, DonationState>(
      listener: (context, state) {
        if (state.status == DonationStatus.success) {
          // Call the onDonationComplete callback with the donation amount
          widget.onDonationComplete(state.amount);

          // Close the modal
          Navigator.of(context).pop();

          // Show a success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Donation of ₹${state.amount} successful!'),
                backgroundColor: success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
              ),
            );
          }
        } else if (state.status == DonationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to process donation'),
              backgroundColor: error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: Colors.grey[800]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Support Argument',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.nodeText,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            _buildAmountDisplay(),
            const SizedBox(height: 16),
            _buildQuickAmountSelector(),
            const SizedBox(height: 24),
            _buildCustomKeyboard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '₹',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _amountString.isEmpty ? '0' : _amountString,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _quickAmounts.map((amount) {
        final isSelected = _amountString == amount;
        return ChoiceChip(
          label: Text('₹$amount'),
          selected: isSelected,
          onSelected: (_) => _selectQuickAmount(amount),
          backgroundColor: Colors.grey[800],
          selectedColor:
              Colors.greenAccent.shade400.withAlpha((0.8 * 255).round()),
          labelStyle: TextStyle(
            color: isSelected ? Colors.black87 : Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey[700]!,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildCustomKeyboard() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'DEL'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map(_buildKeyboardKey).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyboardKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleKeyPress(key),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: key == 'DEL'
                    ? Colors.red.withAlpha((0.15 * 255).round())
                    : Colors.grey[800]?.withAlpha((0.5 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: key == 'DEL'
                  ? Icon(
                      Icons.backspace_outlined,
                      color: Colors.redAccent.shade100,
                      size: 22,
                    )
                  : Text(
                      key,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[200],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final donationCubit = BlocProvider.of<DonationCubit>(context);
    final state = donationCubit.state;

    return Row(
      children: [
        Expanded(
          child: _buildGradientButton(
            text: state.status == DonationStatus.loading
                ? 'Processing...'
                : 'Confirm Donation',
            icon: Icons.check_circle_outline,
            onTap: state.status == DonationStatus.loading
                ? () {}
                : _submitDonation,
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade400, Colors.tealAccent.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            textColor: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
    Color textColor = Colors.white,
  }) {
    final donationCubit = BlocProvider.of<DonationCubit>(context);
    final isLoading = donationCubit.state.status == DonationStatus.loading;

    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black87,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: textColor, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitDonation() {
    HapticFeedback.heavyImpact();
    try {
      final donation = double.tryParse(_amountString) ?? 0.0;

      if (donation <= 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a valid donation amount.'),
            backgroundColor: warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
        return;
      }
      if (donation < 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Minimum donation amount is ₹1.0'),
            backgroundColor: warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
        return;
      }
      if (donation > 5000.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Maximum donation amount is ₹5000.0'),
            backgroundColor: warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
        return;
      }

      // If we have a nodeId, process through the cubit
      if (widget.nodeId.isNotEmpty) {
        BlocProvider.of<DonationCubit>(context).processDonation(
          nodeId: widget.nodeId,
          amount: donation,
        );
      } else {
        // Otherwise, just call the callback directly
        widget.onDonationComplete(donation);
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'DonationModal._submitDonation',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to process donation. Please try again.'),
          backgroundColor: error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }
}
