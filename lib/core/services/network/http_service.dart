// lib/src/services/http_service.dart
import 'package:dio/dio.dart';
import '../models/form_data.dart';

abstract class HttpService {
  String get baseUrl;
  Map<String, String> get headers;

  Future<Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool isAuthenticated = true,
        bool forceRefresh = false,
        CancelToken? cancelToken,
        Map<String, String>? headers, // NEW
      });

  Future<Response> post(
      String endpoint,
       {
        BaseFormData? formData,
        Map<String, dynamic>? queryParameters,
        ContentType contentType = ContentType.formData,
        bool isAuthenticated = false,
        CancelToken? cancelToken,
        Map<String, String>? headers, // NEW
      });

  Future<Response> put(
      String endpoint,
      BaseFormData formData, {
        Map<String, dynamic>? queryParameters,
        bool isAuthenticated = true,
        ContentType contentType = ContentType.json,
        CancelToken? cancelToken,
        Map<String, String>? headers, // NEW
      });

  Future<Response> patch(
      String endpoint,
      BaseFormData formData, {
        Map<String, dynamic>? queryParameters,
        bool isAuthenticated = true,
        ContentType contentType = ContentType.json,
        CancelToken? cancelToken,
        Map<String, String>? headers, // NEW
      });

  Future<String> download(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        void Function(int count, int total)? onReceiveProgress,
        CancelToken? cancelToken,
        Map<String, String>? headers, // NEW
      });

  Future<dynamic> delete();
}

enum ContentType { json, formData,formUrlEncoded }
