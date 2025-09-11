// test/services/services_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:paypal_integration/paypal_intregation.dart';

import 'mocks.mocks.dart'; // generated mock file
import 'package:paypal_integration/core/services/models/form_data.dart';
import 'package:paypal_integration/core/services/network/dio_http_service.dart';

void main() {
  late MockDioHttpService mockHttp;
  late PaypalService paypal;

  setUp(() {
    mockHttp = MockDioHttpService();

    // Stub the getter correctly for Mockito
    when(mockHttp.baseUrl).thenReturn('https://api-m.sandbox.paypal.com');

    paypal = PaypalService(
      clientId: 'test_client',
      secretKey: 'test_secret',
      sandboxMode: true,
      httpService: mockHttp,
    );
  });

  group('PaypalService', () {
    test('createPayment returns approvalUrl & executeUrl', () async {
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

      when(mockHttp.post(
        any,
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => dioResponse);

      final result = await paypal.createPayment(
        accessToken: 'fake_token',
        intent: 'sale',
        transactions: const [],
        returnUrl: 'https://return.example',
        cancelUrl: 'https://cancel.example',
      );

      expect(result['approvalUrl'], 'https://paypal.com/approve');
      expect(result['executeUrl'], 'https://paypal.com/execute');
    });

    test('executePayment returns success', () async {
      final dioResponse = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/execute'),
        statusCode: 200,
        data: {'id': 'PAY-EXECUTED', 'state': 'approved'},
      );

      when(mockHttp.post(
        any,
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => dioResponse);

      final result = await paypal.executePayment(
        accessToken: 'fake_token',
        executeUrl: 'https://api-m.sandbox.paypal.com/execute',
        payerId: 'payer123',
      );

      expect(result['id'], 'PAY-EXECUTED');
    });

    test('captureAuthorization returns capture details', () async {
      final dioResponse = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/capture'),
        statusCode: 201,
        data: {'id': 'CAPTURE-1', 'state': 'completed'},
      );

      when(mockHttp.post(
        any,
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => dioResponse);

      final result = await paypal.captureAuthorization(
        accessToken: 'fake_token',
        authorizationId: 'auth123',
        total: '10.00',
        currency: 'USD',
      );

      expect(result['id'], 'CAPTURE-1');
    });

    test('refundCapture returns refund details', () async {
      final dioResponse = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/refund'),
        statusCode: 200,
        data: {'id': 'RFD-1', 'status': 'COMPLETED'},
      );

      when(mockHttp.post(
        any,
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => dioResponse);

      final result = await paypal.refundCapture(
        accessToken: 'fake_token',
        captureId: 'CAPTURE-1',
        value: '5.00',
        currencyCode: 'USD',
        noteToPayer: 'Partial refund',
      );

      expect(result['status'], 'COMPLETED');
    });

    test('voidAuthorization succeeds with 204', () async {
      final dioResponse = Response(
        requestOptions: RequestOptions(path: '/void'),
        statusCode: 204,
      );

      when(mockHttp.post(
        any,
        formData: anyNamed('formData'),
        contentType: anyNamed('contentType'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => dioResponse);

      expect(
            () async => await paypal.voidAuthorization(
          accessToken: 'fake_token',
          authorizationId: 'auth123',
        ),
        returnsNormally,
      );
    });

    test('getPaymentDetails returns details', () async {
      final dioResponse = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/payment'),
        statusCode: 200,
        data: {'id': 'PAY-123', 'state': 'approved'},
      );

      when(mockHttp.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => dioResponse);

      final result = await paypal.getPaymentDetails(
        accessToken: 'fake_token',
        paymentId: 'PAY-123',
      );

      expect(result['state'], 'approved');
    });

    test('listTransactions returns paged result', () async {
      final dioResponse = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/transactions'),
        statusCode: 200,
        data: {
          'transaction_details': [
            {'transaction_info': {'transaction_id': 'TXN-1'}},
          ]
        },
      );

      when(mockHttp.get(
        any,
        headers: anyNamed('headers'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => dioResponse);

      final result = await paypal.listTransactions(
        accessToken: 'fake_token',
        startDate: '2025-09-01T00:00:00-0700',
        endDate: '2025-09-11T00:00:00-0700',
      );

      expect(result['transaction_details'], isNotEmpty);
    });
  });
}
