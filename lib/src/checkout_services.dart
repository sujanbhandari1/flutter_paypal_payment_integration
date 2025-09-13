// lib/src/services/paypal_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:paypal_integration/core/services/network/http_service.dart';

import '../core/services/models/form_data.dart';
import '../core/services/network/dio_http_service.dart';

class PaypalService {
  final String clientId;
  final String secretKey;
  final bool sandboxMode;

  late final DioHttpService _http;


  PaypalService({
    required this.clientId,
    required this.secretKey,
    required this.sandboxMode,
    DioHttpService? httpService,
  }) {
    _http =
        httpService ??
        DioHttpService(
          baseUrl: sandboxMode
              ? 'https://api-m.sandbox.paypal.com'
              : 'https://api.paypal.com',
        );
  }
  void injectHttp(DioHttpService service) => _http = service; //optional

  // ---------------------------
  // Auth
  // ---------------------------
  getAccessToken() async {
    String baseUrl = sandboxMode
        ? "https://api-m.sandbox.paypal.com"
        : "https://api.paypal.com";

    try {
      var authToken = base64.encode(utf8.encode("$clientId:$secretKey"));
      final response = await Dio().post(
        '$baseUrl/v1/oauth2/token?grant_type=client_credentials',

        options: Options(
          headers: {
            'Authorization': 'Basic $authToken',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      final body = response.data;
      return {
        'error': false,
        'message': "Success",
        'token': body["access_token"],
      };
    } on DioException {
      return {
        'error': true,
        'message': "Your PayPal credentials seems incorrect",
      };
    } catch (e) {
      return {
        'error': true,
        'message': "Unable to proceed, check your internet connection.",
      };
    }
  }

  Map<String, String> _bearer(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // ---------------------------
  // Create Payment
  // ---------------------------
  /// [intent] "sale" (immediate capture) or "authorize" (capture later).
  /// [transactions] should follow v1 schema (amount, item_list, description, etc.)
  /// [returnUrl], [cancelUrl] are your redirect URLs.
  Future<Map<String, dynamic>> createPayment({
    required String accessToken,
    required String intent,
    required List<Map<String, dynamic>> transactions,
    required String returnUrl,
    required String cancelUrl,
    String? noteToPayer,
    String? experienceProfileId,
  }) async {

    final trimmedNote = (noteToPayer ?? '').trim();
    final safeNote = trimmedNote.substring(
      0,
      trimmedNote.length > 165 ? 165 : trimmedNote.length,
    );
    final body = {
      'intent': intent,
      'payer': {'payment_method': 'paypal'},
      'transactions': transactions,
      'redirect_urls': {'return_url': returnUrl, 'cancel_url': cancelUrl},
      if (noteToPayer != null) 'note_to_payer': safeNote,
      if (experienceProfileId != null)
        'experience_profile_id': experienceProfileId,
    };

    final res = await _http.post(
      '/v1/payments/payment',
      formData: BaseFormData(formFields: body),
      contentType: ContentType.json,
      headers: _bearer(accessToken),
    );

    if (res.statusCode == 201) {
      final data = Map<String, dynamic>.from(res.data as Map);
      // convenience: extract approval & execute links
      final links = (data['links'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      final approvalUrl = links.firstWhere(
        (l) => l['rel'] == 'approval_url',
        orElse: () => {},
      )['href'];
      final executeUrl = links.firstWhere(
        (l) => l['rel'] == 'execute',
        orElse: () => {},
      )['href'];

      return {
        'id': data['id'],
        'state': data['state'],
        'approvalUrl': approvalUrl,
        'executeUrl': executeUrl,
        'raw': data,
      };
    }

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: 'Failed to create payment',
      type: DioExceptionType.badResponse,
    );
  }

  // ---------------------------
  // Execute Payment
  // ---------------------------
  /// Use after user approves payment (you’ll receive PayerID on return URL).
  Future<Map<String, dynamic>> executePayment({
    required String accessToken,
    required String executeUrl,
    required String payerId,
  }) async {
    final res = await _http.post(
      executeUrl.replaceFirst(_http.baseUrl, ''), // allow full execute URL
      formData: BaseFormData(formFields: {'payer_id': payerId}),
      contentType: ContentType.json,
      headers: _bearer(accessToken),
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: 'Failed to execute payment',
      type: DioExceptionType.badResponse,
    );
  }

  // ---------------------------
  // Capture Authorized Payment
  // ---------------------------
  /// After an "authorize" intent payment, capture funds with authorizationId.
  Future<Map<String, dynamic>> captureAuthorization({
    required String accessToken,
    required String authorizationId,
    required String total,
    required String currency, // e.g., "USD"
    bool isFinalCapture = true,
  }) async {
    final res = await _http.post(
      '/v1/payments/authorization/$authorizationId/capture',
      formData: BaseFormData(
        formFields: {
          'amount': {'total': total, 'currency': currency},
          'is_final_capture': isFinalCapture,
        },
      ),
      contentType: ContentType.json,
      headers: _bearer(accessToken),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: 'Failed to capture authorization',
      type: DioExceptionType.badResponse,
    );
  }

  /// Capture a payment with paymentId.
  ///
  Future<Map<String, dynamic>> refundCapture({
    required String accessToken,
    required String captureId,
    String? value, // required for partial refunds
    String? currencyCode,
    String? noteToPayer,
  }) async {
    final body = <String, dynamic>{};

    if (value != null && currencyCode != null) {
      body['amount'] = {'value': value, 'currency_code': currencyCode};
    }
    if (noteToPayer != null) {
      body['note_to_payer'] = noteToPayer;
    }

    try {
      final res = await _http.post(
        '/v2/payments/captures/$captureId/refund',
        contentType: ContentType.json,
        headers: _bearer(accessToken),
      );

      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        "Refund failed with status-code ${e.response?.statusCode}",
      );
    }
  }

  // ---------------------------
  // Void an Authorization
  // ---------------------------
  Future<void> voidAuthorization({
    required String accessToken,
    required String authorizationId,
  }) async {
    final res = await _http.post(
      '/v1/payments/authorization/$authorizationId/void',
      formData: BaseFormData(formFields: const {}),
      contentType: ContentType.json,
      headers: _bearer(accessToken),
    );

    if (res.statusCode != 204) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'Failed to void authorization',
        type: DioExceptionType.badResponse,
      );
    }
  }

  // ---------------------------
  // Get Payment Details
  // ---------------------------
  Future<Map<String, dynamic>> getPaymentDetails({
    required String accessToken,
    required String paymentId,
  }) async {
    final res = await _http.get(
      '/v1/payments/payment/$paymentId',
      headers: _bearer(accessToken),
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: 'Failed to get payment details',
      type: DioExceptionType.badResponse,
    );
  }

  // ---------------------------
  // List Transaction History (Reporting API)
  // ---------------------------
  /// Dates must be ISO8601 with timezone, e.g. "2025-09-01T00:00:00-0700"
  Future<Map<String, dynamic>> listTransactions({
    required String accessToken,
    required String startDate,
    required String endDate,
    String? transactionStatus,
    int page = 1,
    int pageSize = 20,
    String? fields,
    String? balanceAffectingRecordsOnly,
  }) async {
    final res = await _http.get(
      '/v1/reporting/transactions',
      headers: _bearer(accessToken),

      queryParameters: {
        'start_date': startDate,
        'end_date': endDate,
        'page_size': pageSize,
        'page': page,
        if (transactionStatus != null) 'transaction_status': transactionStatus,
        if (fields != null) 'fields': fields,
        if (balanceAffectingRecordsOnly != null)
          'balance_affecting_records_only': balanceAffectingRecordsOnly,
      },
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: 'Failed to list transactions',
      type: DioExceptionType.badResponse,
    );
  }
}
