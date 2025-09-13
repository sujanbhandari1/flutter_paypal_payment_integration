// Import necessary packages for Flutter UI, InAppWebView, and local checkout services.
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'checkout_services.dart';

/// A Flutter widget that provides a PayPal checkout experience using an InAppWebView.
class PaypalCheckoutView extends StatefulWidget {
  /// Your PayPal client ID.
  final String clientId;

  /// Your PayPal secret key.
  final String secretKey;

  /// Set to true for sandbox mode (testing), false for live mode.
  final bool sandboxMode;

  /// A list of transactions to be processed. Each transaction is a map.
  /// Example:
  ///
  final List<Map<String, dynamic>> transactions;

  final String returnUrl;
  final String cancelUrl;

  /// Callbacks
  final Function(Map<String, dynamic> data) onSuccess;
  final Function(dynamic error) onError;
  final VoidCallback onCancel;

  final Widget? loadingIndicator;
  final PaypalService? paypalService;

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
    this.paypalService, // add this
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
    try {
      final tokenResponse = await _paypal.getAccessToken();
      debugPrint('⨝⨹⨹⨹⨝ PaypalService To String Map $tokenResponse');
      final token = tokenResponse['token']; // ✅ Extract string here

      final payment = await _paypal.createPayment(
        accessToken: token,
        intent: 'sale',
        transactions: widget.transactions,
        returnUrl: widget.returnUrl,
        cancelUrl: widget.cancelUrl,
      );
      debugPrint('⨝⨹⨹⨹⨝ PaypalService To String Map $payment');

      setState(() {
        _accessToken = token;
        _approvalUrl = payment['approvalUrl'];
        _executeUrl = payment['executeUrl'];
      });
    } catch (e) {
      debugPrint('⨝⨹⨹⨹⨝ PaypalService To String Map $e');
      widget.onError(e);
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
    } catch (e) {
      widget.onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_approvalUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PayPal Payment')),
        body: Center(
          child: widget.loadingIndicator ?? const CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PayPal Checkout')),
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
          if (_progress < 1.0) LinearProgressIndicator(value: _progress),
        ],
      ),
    );
  }
}
