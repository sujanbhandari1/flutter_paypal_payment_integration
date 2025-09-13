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

  /// Optional customization for checkout page
  final AppBar? checkoutAppBar;
  final Color? checkoutBackgroundColor;
  final Widget? checkoutLoadingIndicator;

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
    this.checkoutAppBar,
    this.checkoutBackgroundColor,
    this.checkoutLoadingIndicator,
  });

  void _handlePayment(BuildContext context) {
    if (!enabled) return; // Do nothing if disabled

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled')),
            );
            onCancel?.call();
          },
          appBar: checkoutAppBar,
          backgroundColor: checkoutBackgroundColor,
          loadingIndicator: checkoutLoadingIndicator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use withAlpha instead of deprecated withOpacity
    final currentBackground = enabled
        ? backgroundColor
        : backgroundColor.withAlpha((255 * 0.5).toInt()); // 50% alpha
    final currentTextColor = enabled
        ? textColor
        : textColor.withAlpha((255 * 0.5).toInt()); // 50% alpha

    return GestureDetector(
      onTap: () => _handlePayment(context),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: currentBackground,
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
                color: currentTextColor,
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
