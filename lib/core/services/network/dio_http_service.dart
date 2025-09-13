// lib/src/services/dio_http_service.dart
import 'package:dio/dio.dart';
import '../models/form_data.dart';
import 'http_service.dart';

class DioHttpService implements HttpService {
  final Dio _dio;

  @override
  final String baseUrl;

  @override
  final Map<String, String> headers;

  DioHttpService({required this.baseUrl, this.headers = const {}})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl, headers: headers));

  String _mapContentType(ContentType type) => type == ContentType.json
      ? type == ContentType.formUrlEncoded
            ? 'application/x-www-form-urlencoded'
            : 'application/json'
      : 'multipart/form-data';

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    bool forceRefresh = false,
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) {
    return _dio.get(
      endpoint,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(headers: headers),
    );
  }

  @override
  Future<Response> post(
    String endpoint, { // <-- make it optional
    BaseFormData? formData,
    Map<String, dynamic>? queryParameters,
    ContentType contentType = ContentType.formData,
    bool isAuthenticated = false,
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) async {
    dynamic data;
    if (formData != null) {
      data = contentType == ContentType.json
          ? formData.nonNullFormFields
          : await formData.toFormData;
    }
    return _dio.post(
      endpoint,
      data: data, // will be null if not provided
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        headers: headers,
        contentType: _mapContentType(contentType),
      ),
    );
  }

  @override
  Future<Response> put(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    ContentType contentType = ContentType.json,
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) async {
    final data = contentType == ContentType.json
        ? formData.nonNullFormFields
        : await formData.toFormData;

    return _dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        headers: headers,
        contentType: _mapContentType(contentType),
      ),
    );
  }

  @override
  Future<Response> patch(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    ContentType contentType = ContentType.json,
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) async {
    final data = contentType == ContentType.json
        ? formData.nonNullFormFields
        : await formData.toFormData;

    return _dio.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        headers: headers,
        contentType: _mapContentType(contentType),
      ),
    );
  }

  @override
  Future<String> download(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    void Function(int count, int total)? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, String>? headers,
  }) async {
    final savePath = '/tmp/download_${DateTime.now().millisecondsSinceEpoch}';
    await _dio.download(
      endpoint,
      savePath,
      queryParameters: queryParameters,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      options: Options(headers: headers),
    );
    return savePath;
  }

  @override
  Future delete() => _dio.delete('/');
}
