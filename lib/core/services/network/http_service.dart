import 'package:dio/dio.dart';


/// Http Service Interface
abstract class HttpService {
  /// Http base url
  String get baseUrl;

  /// Http headers
  Map<String, String> get headers;

  /// Http get request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  });

  /// Http post request
  Future<Response> post(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    ContentType contentType = ContentType.formData,
    bool isAuthenticated = false,
    CancelToken? cancelToken,
  });

  /// Http put request
  Future<Response> put(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    ContentType contentType = ContentType.json,
    CancelToken? cancelToken,
  });

  /// Http patch request
  Future<Response> patch(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    ContentType contentType = ContentType.json,
    CancelToken? cancelToken,
  });

  /// Http get request
  Future<String> download(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    void Function(int count, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  });

  /// Http delete request
  Future<dynamic> delete();
}

/// Content Type
enum ContentType {
  json,
  formData,
}
