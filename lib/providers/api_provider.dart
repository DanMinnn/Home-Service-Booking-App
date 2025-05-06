import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/utils/token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/error_response.dart';

class ApiProvider {
  late Dio _dio;
  String? get _accessToken {
    return TokenManager().accessToken;
  }

  static final ApiProvider _instance = ApiProvider._internal();
  LogProvider get logger => const LogProvider('Api Provider');
  factory ApiProvider() {
    return _instance;
  }

  ApiProvider._internal() {
    final baseOption = BaseOptions(
      baseUrl: dotenv.env['API_URL']!,
      connectTimeout: const Duration(seconds: 30), // Add a 30-second timeout
      receiveTimeout: const Duration(seconds: 30),
    );
    _dio = Dio(baseOption);
    setupInterceptors();
  }

  void setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      logger.log('[${options.method}] - ${options.uri}');

      if (_accessToken == null || _accessToken!.isEmpty) {
        return SharedPreferences.getInstance().then((prefs) {
          TokenManager().load(prefs);
          logger.log('calling with access token: $_accessToken');
          options.headers['Authorization'] = 'Bearer $_accessToken';
          options.headers.remove('Authorization');
          return handler.next(options);
        });
      }
      options.headers['Authorization'] = 'Bearer $_accessToken';
      options.headers.remove('Authorization');
      return handler.next(options);
    }, onResponse: (response, handler) {
      return handler.next(response);
    }, onError: (DioException e, ErrorInterceptorHandler handler) async {
      logger.log(e.response.toString());
      return handler.next(e);
    }));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final res = await _dio.get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);

    if (res is! ErrorResponse) return res;
    throw res;
  }

  Future<Response> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final res = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    if (res is! ErrorResponse) {
      return res;
    }
    throw res;
  }

  Future<Response> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final res = await _dio.delete(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);

    if (res is! ErrorResponse) return res;
    throw res;
  }
}
