// test/integration/paypal_service_full_integration_test.dart
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

  // ⚠️ Use sandbox payer ID here, NOT email
  const sandboxBuyerPayerId = 'P4DFGHGXJ2XCA';

  late PaypalService paypal;

  setUp(() {
    // Create Dio instance with logging
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

    // Initialize PayPal service with Dio
    paypal = PaypalService(
      clientId: clientId,
      secretKey: secretKey,
      sandboxMode: sandboxMode,
    );
  });

  test('Full automated PayPal flow', () async {
    // 1️⃣ Get access token
    final tokenResponse = await paypal.getAccessToken();
    expect(tokenResponse['error'], false);
    final accessToken = tokenResponse['token'] as String;

    // 2️⃣ Create payment
    final paymentResponse = await paypal.createPayment(
      accessToken: accessToken,
      intent: 'sale', // immediate capture
      transactions: [
        {
          'amount': {'total': '10.00', 'currency': 'USD'},
          'description': 'Automated Integration Test Payment',
        }
      ],
      returnUrl: 'https://example.com/return',
      cancelUrl: 'https://example.com/cancel',
    );

    expect(paymentResponse['id'], isNotNull);
    expect(paymentResponse['approvalUrl'], isNotNull);
    expect(paymentResponse['executeUrl'], isNotNull);

    print('Payment created with ID: ${paymentResponse['id']}');

    // 3️⃣ Execute payment using sandbox payer ID
    final executedPayment = await paypal.executePayment(
      accessToken: accessToken,
      executeUrl: paymentResponse['executeUrl'],
      payerId: sandboxBuyerPayerId,
    );

    expect(executedPayment['id'], paymentResponse['id']);
    expect(executedPayment['state'], 'approved');

    print('Payment executed successfully');

    // 4️⃣ Refund payment
    final captureId =
    executedPayment['transactions'][0]['related_resources'][0]['sale']['id'];
    final refundResponse = await paypal.refundCapture(
      accessToken: accessToken,
      captureId: captureId,
      value: '10.00',
      currencyCode: 'USD',
      noteToPayer: 'Automated test refund',
    );

    expect(refundResponse['status'], 'COMPLETED');
    print('Refund completed successfully');

    // 5️⃣ Get payment details
    final paymentDetails = await paypal.getPaymentDetails(
      accessToken: accessToken,
      paymentId: paymentResponse['id'],
    );
    expect(paymentDetails['id'], paymentResponse['id']);
    print('Payment details retrieved');

    // 6️⃣ List transactions (last 7 days)
    final transactions = await paypal.listTransactions(
      accessToken: accessToken,
      startDate: DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String(),
      endDate: DateTime.now().toIso8601String(),
    );

    expect(transactions, isNotNull);
    print('Transactions listed successfully');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
