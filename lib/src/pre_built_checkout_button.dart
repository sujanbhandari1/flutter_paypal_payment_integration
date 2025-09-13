import 'package:flutter/material.dart';
import '../paypal_integration.dart';

/// A pre-built PayPal payment button that triggers the checkout flow.
class PaypalPaymentButton extends StatelessWidget {
  final String clientId;
  final String secretKey;
  final bool sandboxMode;
  final List<Map<String, dynamic>> transactions;

  final String returnUrl;
  final String cancelUrl;

  final Function(Map<String, dynamic>)? onSuccess;
  final Function(dynamic)? onError;
  final VoidCallback? onCancel;

  /// UI customization
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final double width;
  final String text;
  final Widget? icon;

  /// Enable/disable button
  final bool enabled;

  const PaypalPaymentButton({
    super.key,
    required this.clientId,
    required this.secretKey,
    required this.transactions,
    required this.returnUrl,
    required this.cancelUrl,
    this.sandboxMode = true,
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.height = 50,
    this.width = double.infinity,
    this.text = 'Pay with PayPal',
    this.icon,
    this.enabled = true,
  });

  void _handlePayment(BuildContext context) {
    if (!enabled) return; // Disable tap if button is not enabled

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaypalCheckoutView(
          clientId: clientId,
          secretKey: secretKey,
          sandboxMode: sandboxMode,
          transactions: transactions,
          returnUrl: returnUrl,
          cancelUrl: cancelUrl,
          onSuccess: (data) {
            // Default success screen
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Payment Successful'),
                content: Text(data.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            onSuccess?.call(data);
          },
          onError: (error) {
            // Default error screen
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Payment Failed'),
                content: Text(error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            onError?.call(error);
          },
          onCancel: () {
            // Default cancel screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled')),
            );
            onCancel?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _handlePayment(context) : null,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor.withOpacity(enabled ? 1 : 0.6),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
