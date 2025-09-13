// lib/src/widgets/paypal_checkout_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../paypal_integration.dart';

/// A Flutter widget that provides a PayPal checkout experience using an InAppWebView.
class PaypalCheckoutView extends StatefulWidget {
  final String clientId;
  final String secretKey;
  final bool sandboxMode;
  final List<Map<String, dynamic>> transactions;
  final String returnUrl;
  final String cancelUrl;

  /// Callbacks
  final Function(Map<String, dynamic> data) onSuccess;
  final Function(dynamic error) onError;
  final VoidCallback onCancel;

  /// Optional customization
  final Widget? loadingIndicator;
  final PaypalService? paypalService;
  final AppBar? appBar;
  final Color? backgroundColor;

  const PaypalCheckoutView({
    super.key,
    required this.clientId,
    required this.secretKey,
    required this.transactions,
    required this.returnUrl,
    required this.cancelUrl,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
    this.sandboxMode = false,
    this.loadingIndicator,
    this.paypalService,
    this.appBar,
    this.backgroundColor,
  });

  @override
  State<PaypalCheckoutView> createState() => _PaypalCheckoutViewState();
}

class _PaypalCheckoutViewState extends State<PaypalCheckoutView> {
  late PaypalService _paypal;
  String? _approvalUrl;
  String? _executeUrl;
  String? _accessToken;
  double _progress = 0;

  bool _hasError = false;
  String _errorMessage = '';
  bool _paymentSuccess = false;
  Map<String, dynamic>? _successData;

  @override
  void initState() {
    super.initState();
    _paypal =
        widget.paypalService ??
            PaypalService(
              clientId: widget.clientId,
              secretKey: widget.secretKey,
              sandboxMode: widget.sandboxMode,
            );
    _createPayment();
  }

  Future<void> _createPayment() async {
    setState(() {
      _hasError = false;
      _paymentSuccess = false;
      _approvalUrl = null;
      _executeUrl = null;
      _accessToken = null;
    });

    try {
      final tokenResponse = await _paypal.getAccessToken();
      final token = tokenResponse['token'];

      final payment = await _paypal.createPayment(
        accessToken: token,
        intent: 'sale',
        transactions: widget.transactions,
        returnUrl: widget.returnUrl,
        cancelUrl: widget.cancelUrl,
      );

      setState(() {
        _accessToken = token;
        _approvalUrl = payment['approvalUrl'];
        _executeUrl = payment['executeUrl'];
      });
    } catch (e) {
      widget.onError(e);
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _executePayment(String payerId) async {
    try {
      final executed = await _paypal.executePayment(
        accessToken: _accessToken!,
        executeUrl: _executeUrl!,
        payerId: payerId,
      );
      widget.onSuccess(executed);
      setState(() {
        _paymentSuccess = true;
        _successData = executed;
      });
    } catch (e) {
      widget.onError(e);
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final appBar = widget.appBar ?? AppBar(title: const Text('PayPal Checkout'));

    // Payment failed UI
    if (_hasError) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Payment Failed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createPayment,
                  child: const Text('Retry Payment'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Payment success UI
    if (_paymentSuccess && _successData != null) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaction ID: ${_successData!['id'] ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Payment loading UI
    if (_approvalUrl == null) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: bgColor,
        body: Center(
          child: widget.loadingIndicator ?? const CircularProgressIndicator(),
        ),
      );
    }

    // WebView checkout
    return Scaffold(
      appBar: appBar,
      backgroundColor: bgColor,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_approvalUrl!)),
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (controller, navAction) async {
              final url = navAction.request.url.toString();
              if (url.startsWith(widget.returnUrl)) {
                final payerId = Uri.parse(url).queryParameters['PayerID'];
                if (payerId != null) {
                  _executePayment(payerId);
                } else {
                  widget.onError('Missing PayerID');
                  setState(() {
                    _hasError = true;
                    _errorMessage = 'Missing PayerID';
                  });
                }
                return NavigationActionPolicy.CANCEL;
              }
              if (url.startsWith(widget.cancelUrl)) {
                widget.onCancel();
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress),
        ],
      ),
    );
  }
}
