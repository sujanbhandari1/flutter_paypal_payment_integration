// test/services/paypal_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'mocks.mocks.dart'; // generated mock file
import 'package:paypal_integration/src/checkout_services.dart';

void main() {
  late MockDioHttpService mockHttp;
  late PaypalService paypal;

  setUp(() {
    mockHttp = MockDioHttpService();
    // inject the mock http service via constructor
    paypal = PaypalService(
      clientId: 'test_client',
      secretKey: 'test_secret',
      sandboxMode: true,
      httpService: mockHttp,
    );
  });

  test('createPayment returns approvalUrl and executeUrl on 201', () async {
    // Arrange: build the response body PayPal would return
    final responseData = {
      'id': 'PAY-123',
      'state': 'created',
      'links': [
        {'rel': 'approval_url', 'href': 'https://paypal.com/approve'},
        {'rel': 'execute', 'href': 'https://paypal.com/execute'},
      ]
    };

    final dioResponse = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/v1/payments/payment'),
      statusCode: 201,
      data: responseData,
    );

    // Stub the mock: any path, any named params -> return dioResponse
    when(
      mockHttp.post(
        any,
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      ),
    ).thenAnswer((_) async => dioResponse);

    // Act
    final result = await paypal.createPayment(
      accessToken: 'fake_token',
      intent: 'sale',
      transactions: const [],
      returnUrl: 'https://return.example',
      cancelUrl: 'https://cancel.example',
    );

    // Assert
    expect(result['approvalUrl'], 'https://paypal.com/approve');
    expect(result['executeUrl'], 'https://paypal.com/execute');

    // verify the mock was used with the expected endpoint
    verify(
      mockHttp.post(
        '/v1/payments/payment',
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      ),
    ).called(1);
  });

  test('createPayment throws DioException when statusCode != 201', () async {
    // Arrange: a non-201 response
    final dioResponse = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/v1/payments/payment'),
      statusCode: 400,
      data: {'message': 'bad request'},
    );

    when(
      mockHttp.post(
        any,
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      ),
    ).thenAnswer((_) async => dioResponse);

    // Act & Assert: expect a DioException to be thrown (as per createPayment code)
    expect(
          () async => await paypal.createPayment(
        accessToken: 'fake_token',
        intent: 'sale',
        transactions: const [],
        returnUrl: 'https://return.example',
        cancelUrl: 'https://cancel.example',
      ),
      throwsA(isA<DioException>()),
    );
  });
}
