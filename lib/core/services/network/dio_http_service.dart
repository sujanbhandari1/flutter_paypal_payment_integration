import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/flavor/configuration.dart';
import '../router/app_router.dart';
import '../../../utils/extension_functions.dart';
import '../storage/storage_keys.dart';
import 'http_exception.dart';
import '../storage/storage_service.dart';
import 'http_cache_interceptor.dart';
import 'http_service.dart';
import 'models/form_data.dart';

/// Http service implementation using the Dio package
///
/// See https://pub.dev/packages/dio
class DioHttpService implements HttpService {
  /// Creates new instance of [DioHttpService]
  DioHttpService(
    this.config,
    this.storageService, {
    Dio? dioOverride,
    bool enableCaching = true,
  }) {
    dio = dioOverride ?? Dio(baseOptions);
    if (enableCaching) {
      dio.interceptors.add(CacheInterceptor(config, storageService));
    }
  }

  /// Flavor Configuration
  ///
  final Configuration config;

  /// Storage service used for caching http responses
  final StorageService storageService;

  /// The Dio Http client
  late final Dio dio;

  /// The Dio base options
  BaseOptions get baseOptions => BaseOptions(
        baseUrl: baseUrl,
        // followRedirects: false,
        // validateStatus: (status) {
        //   return status! < 500;
        // },
        // receiveDataWhenStatusError: true,
        headers: headers,
        connectTimeout: const Duration(minutes: 2), // 2 minutes
        receiveTimeout: const Duration(minutes: 2), // 2 minutes
      );

  @override
  String get baseUrl => config.apiBaseUrlV2;

  @override
  Map<String, String> headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
    'referer': 'https://staging.nexs.io/',
  };

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
    bool isAuthenticated = false,
    String? customBaseUrl,
    CancelToken? cancelToken,
  }) async {
    dio.options.extra[config.dioCacheForceRefreshKey] = forceRefresh;

    Map<String, String> updatedHeaders = {...headers};

    if (isAuthenticated) {
      updatedHeaders["Authorization"] =
          'JWT ${storageService.get(StorageKeys.loggedInUserToken)}';
    }

    try {
      final Response response = await dio.get(
        endpoint,
        options: Options(headers: updatedHeaders),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      return response;
    } catch (e) {
      throw HttpException(
        title: 'Http Error!',
        statusCode: e is DioException ? e.response?.statusCode : 500,
        message: e is DioException
            ? e.type == DioExceptionType.connectionError
                ? AppRouter.rootNavigatorKey.currentContext?.appLocalization
                        .no_internet_connection ??
                    'No active internet connection'
                : e.message
            : AppRouter.rootNavigatorKey.currentContext?.appLocalization
                    .request_handle_err ??
                "Unable to handle your request",
        dioException: e is DioException ? e : null,
      );
    }
  }

  @override
  Future<Response> post(
      String endpoint,
      BaseFormData formData, {
        Map<String, dynamic>? queryParameters,
        ContentType contentType = ContentType.formData,
        bool isAuthenticated = false,
        CancelToken? cancelToken,
      }) async {
    Map<String, String> updatedHeaders = {...headers};

    if (isAuthenticated) {
      updatedHeaders["Authorization"] =
      'JWT ${storageService.get(StorageKeys.loggedInUserToken)}';
    }

    if (contentType == ContentType.formData) {
      updatedHeaders['content-type'] = 'multipart/form-data';
    }

    try {
      final Response response = await dio.post(
        endpoint,
        data: contentType == ContentType.formData
            ? await formData.toFormData
            : formData.nonNullFormFields,
        queryParameters: queryParameters,
        options: Options(
          headers: updatedHeaders,
          extra: {
            config.dioCacheForceRefreshKey: true, // ✅ required to skip cache
          },
        ),
        cancelToken: cancelToken,
      );


      return response;
    } catch (e) {
      throw HttpException(
        title: 'Http Error!',
        statusCode: e is DioException ? e.response?.statusCode : 500,
        message: e is DioException
            ? e.type == DioExceptionType.connectionError
            ? AppRouter.rootNavigatorKey.currentContext?.appLocalization
            .no_internet_connection ??
            'No active internet connection'
            : e.message
            : AppRouter.rootNavigatorKey.currentContext?.appLocalization
            .request_handle_err ??
            "Unable to handle your request",
        dioException: e is DioException ? e : null,
      );
    }
  }

  @override
  Future<Response> put(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = false,
    ContentType contentType = ContentType.json,
    CancelToken? cancelToken,
  }) async {
    dio.options.extra[config.dioCacheForceRefreshKey] = true;

    Map<String, String> updatedHeaders = {...headers};

    if (isAuthenticated) {
      updatedHeaders["Authorization"] =
          'JWT ${storageService.get(StorageKeys.loggedInUserToken)}';
    }

    if (contentType == ContentType.formData) {
      updatedHeaders['content-type'] = 'multipart/form-data';
    }

    try {
      final Response response = await dio.put(
        endpoint,
        data: contentType == ContentType.formData
            ? await formData.toFormData
            : formData.nonNullFormFields,
        queryParameters: queryParameters,
        options: Options(headers: updatedHeaders),
        cancelToken: cancelToken,
      );

      return response;
    } catch (e) {
      throw HttpException(
        title: 'Http Error!',
        statusCode: e is DioException ? e.response?.statusCode : 500,
        message: e is DioException
            ? e.type == DioExceptionType.connectionError
                ? AppRouter.rootNavigatorKey.currentContext?.appLocalization
                        .no_internet_connection ??
                    'No active internet connection'
                : e.message
            : AppRouter.rootNavigatorKey.currentContext?.appLocalization
                    .request_handle_err ??
                "Unable to handle your request",
        dioException: e is DioException ? e : null,
      );
    }
  }

  @override
  Future<Response> patch(
    String endpoint,
    BaseFormData formData, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
    ContentType contentType = ContentType.json,
    CancelToken? cancelToken,
  }) async {
    dio.options.extra[config.dioCacheForceRefreshKey] = true;

    Map<String, String> updatedHeaders = {...headers};

    if (isAuthenticated) {
      updatedHeaders["Authorization"] =
          'JWT ${storageService.get(StorageKeys.loggedInUserToken)}';
    }

    if (contentType == ContentType.formData) {
      updatedHeaders['content-type'] = 'multipart/form-data';
    }

    try {
      final Response response = await dio.patch(
        endpoint,
        data: contentType == ContentType.formData
            ? await formData.toFormData
            : formData.nonNullFormFields,
        queryParameters: queryParameters,
        options: Options(headers: updatedHeaders),
        cancelToken: cancelToken,
      );

      return response;
    } catch (e) {
      throw HttpException(
        title: 'Http Error!',
        statusCode: e is DioException ? e.response?.statusCode : 500,
        message: e is DioException
            ? e.type == DioExceptionType.connectionError
                ? AppRouter.rootNavigatorKey.currentContext?.appLocalization
                        .no_internet_connection ??
                    'No active internet connection'
                : e.message
            : AppRouter.rootNavigatorKey.currentContext?.appLocalization
                    .request_handle_err ??
                "Unable to handle your request",
        dioException: e is DioException ? e : null,
      );
    }
  }

  @override
  Future<dynamic> delete() {
    throw UnimplementedError();
  }

  Future<String> download(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        void Function(int count, int total)? onReceiveProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      // Request storage permission
      PermissionStatus status = await Permission.storage.request();

      if (Platform.isAndroid && await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      if (!status.isGranted) {
        Fluttertoast.showToast(msg: "❌ Storage permission denied. Enable it in settings.");
        throw Exception("Storage permission denied");
      }

      // Get external storage directory
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Failed to get storage directory");
      }

      // Extract filename from URL
      String fileName = endpoint.split('/').last;
      String savePath = "${directory.path}/$fileName";

      // Start file download
      await dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: Options(followRedirects: false, receiveTimeout: Duration.zero),
      );

      print("✅ File downloaded to: $savePath");
      return savePath;
    } catch (e) {
      throw Exception("Download failed: $e");
    }
  }



  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.status;

      if (status.isDenied || status.isRestricted) {
        status = await Permission.storage.request();
      }

      // If permanently denied, guide user to settings
      if (status.isPermanentlyDenied) {
        Fluttertoast.showToast(msg: "Storage permission required! Please enable it in settings.");
        openAppSettings(); // Open app settings to manually enable permissions
        return false;
      }

      return status.isGranted;
    }
    return true; // For non-Android platforms, assume permission is granted
  }


}
