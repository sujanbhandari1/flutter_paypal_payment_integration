import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paypal_integration/paypal_intregation.dart';
import 'package:dio/dio.dart';

void main() {
  // Replace with your sandbox credentials
  const clientId =
      "AfDlfuKlj48GElNvFRld1LZIPGAhIbyCm0MLHuhlznh0nl_eX5YiEmJHAJPVzemw0waxHIRH4sdg1It1";
  const secretKey =
      "EHkjluknVRt7RemM3BMP6q5WCB2xkOJ_LI4K7BBLCiGMyFOGDpR5zCVdTMXdJ9h5k2l2-zudQ8UjJnWp";
  const sandboxMode = true;

  late PaypalService paypal;

  setUp(() {
    final dio = Dio();
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    paypal = PaypalService(
      clientId: clientId,
      secretKey: secretKey,
      sandboxMode: sandboxMode,
    );
  });

  test('Manual approval PayPal flow with refund, capture & transactions', () async {
    // 1️⃣ Get access token
    final tokenResponse = await paypal.getAccessToken();
    expect(tokenResponse['error'], false);
    final accessToken = tokenResponse['token'] as String;

    // 2️⃣ Start a single local HTTP server for all redirects
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

    final saleCompleter = Completer<Map<String, String>>();
    final authCompleter = Completer<Map<String, String>>();

    server.listen((HttpRequest request) async {
      final params = request.uri.queryParameters;

      // Respond to user in browser
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write("<h2>Payment approved ✅ You can close this tab.</h2>");
      await request.response.close();

      // Complete the appropriate completer
      if (!saleCompleter.isCompleted) {
        saleCompleter.complete(params);
      } else if (!authCompleter.isCompleted) {
        authCompleter.complete(params);
      }
    });

    // 3️⃣ Create payment (sale intent)
    final paymentResponse = await paypal.createPayment(
      accessToken: accessToken,
      intent: 'sale',
      transactions: [
        {
          'amount': {'total': '10.00', 'currency': 'USD'},
          'description': 'Integration Test Payment',
        }
      ],
      returnUrl: 'http://localhost:8080/return',
      cancelUrl: 'http://localhost:8080/cancel',
    );


    // 4️⃣ Wait for user approval (sale)
    final saleRedirectParams = await saleCompleter.future;
    final salePayerId = saleRedirectParams['PayerID'];

    // 5️⃣ Execute payment (sale)
    final executedPayment = await paypal.executePayment(
      accessToken: accessToken,
      executeUrl: paymentResponse['executeUrl'],
      payerId: salePayerId!,
    );

    expect(executedPayment['id'], paymentResponse['id']);
    expect(executedPayment['state'], 'approved');

    // 6️⃣ Refund the sale payment
    final captureId = executedPayment['transactions'][0]['related_resources'][0]['sale']['id'];

    final refundResponse = await paypal.refundCapture(
      accessToken: accessToken,
      captureId: captureId,
      value: '10.00',
      currencyCode: 'USD',
      noteToPayer: 'Automated integration test refund',
    );

    expect(refundResponse['status'], 'COMPLETED');

    // 7️⃣ Get payment details
    final paymentDetails = await paypal.getPaymentDetails(
      accessToken: accessToken,
      paymentId: paymentResponse['id'],
    );

    expect(paymentDetails['id'], paymentResponse['id']);

    // 8️⃣ List transactions (last 7 days)
    String formatForPaypal(DateTime dt) {
      final offset = dt.timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final hours = offset.inHours.abs().toString().padLeft(2, '0');
      final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final tz = '$sign$hours$minutes';
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}T'
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}$tz';
    }

    final startDate = formatForPaypal(DateTime.now().subtract(const Duration(days: 7)));
    final endDate = formatForPaypal(DateTime.now());

    final transactions = await paypal.listTransactions(
      accessToken: accessToken,
      startDate: startDate,
      endDate: endDate,
      fields: 'all',
      pageSize: 40,
      page: 1,
    );

    expect(transactions, isNotNull);

    // 9️⃣ Authorization → Capture flow
    final authPayment = await paypal.createPayment(
      accessToken: accessToken,
      intent: 'authorize',
      transactions: [
        {
          'amount': {'total': '5.00', 'currency': 'USD'},
          'description': 'Authorization test',
        }
      ],
      returnUrl: 'http://localhost:8080/return',
      cancelUrl: 'http://localhost:8080/cancel',
    );


    final authRedirectParams = await authCompleter.future;
    final authPayerId = authRedirectParams['PayerID'];

    final executedAuthPayment = await paypal.executePayment(
      accessToken: accessToken,
      executeUrl: authPayment['executeUrl'],
      payerId: authPayerId!,
    );

    final relatedResources = executedAuthPayment['transactions'][0]['related_resources'];
    if (relatedResources.isEmpty || relatedResources[0]['authorization'] == null) {
      fail('Authorization not returned by PayPal sandbox. Cannot capture.');
    }

    final authorizationId = relatedResources[0]['authorization']['id'];

    // Capture the authorized payment
    final captureResponse = await paypal.captureAuthorization(
      accessToken: accessToken,
      authorizationId: authorizationId,
      total: '5.00',
      currency: 'USD',
      isFinalCapture: true,
    );

    expect(captureResponse['status'], 'COMPLETED');

    // Close the server after all flows
    await server.close();
  }, timeout: const Timeout(Duration(minutes: 15)));
}
