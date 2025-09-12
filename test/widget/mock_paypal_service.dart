import 'package:paypal_integration/paypal_intregation.dart';

class FakePaypalService extends PaypalService {
  FakePaypalService()
      : super(clientId: 'dummy', secretKey: 'dummy', sandboxMode: true);

  @override
  Future<Map<String, dynamic>> getAccessToken() async {
    return {'error': false, 'token': 'dummy_token'};
  }

  @override
  Future<Map<String, dynamic>> createPayment({
    required String accessToken,
    required String intent,
    required List<Map<String, dynamic>> transactions,
    required String returnUrl,
    required String cancelUrl,
    String? noteToPayer,
    String? experienceProfileId,
  }) async {
    return {
      'approvalUrl': 'https://dummy.approve.url',
      'executeUrl': 'https://dummy.execute.url',
      'id': 'PAY-123',
      'state': 'created',
      'raw': {},
    };
  }

  @override
  Future<Map<String, dynamic>> executePayment({
    required String accessToken,
    required String executeUrl,
    required String payerId,
  }) async {
    return {'id': 'PAY-EXECUTED', 'state': 'approved'};
  }
}
