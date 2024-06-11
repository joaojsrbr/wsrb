import 'dart:convert';

import 'package:dio/dio.dart' as dio;

import '../interfaces/http_service.dart';
import '../utils/custom_log.dart';

class _DioStatus extends dio.Interceptor {
  Stopwatch? _stopwatch;

  @override
  void onRequest(
      dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    _stopwatch = Stopwatch()..start();
    final message = 'REQUEST[${options.method}] => PATH: ${options.path}';
    customLog(message);
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
      dio.Response response, dio.ResponseInterceptorHandler handler) {
    _stopwatch?.stop();

    final requestDuration = _stopwatch?.elapsed;
    String message =
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}';

    if (requestDuration != null) {
      message =
          'RESPONSE[${response.statusCode}][${_format(requestDuration)}] => PATH: ${response.requestOptions.path}';
      _stopwatch = null;
    }

    customLog(message);
    return super.onResponse(response, handler);
  }

  String _format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0").replaceFirst("00:", "");

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    // customLog(err.message ?? '', error: err);
    customLog('ERROR[${err.runtimeType}]: ${err.message}',
        stackTrace: err.stackTrace);
    super.onError(err, handler);
  }
}

class DioClient
    implements IHttpService<dio.ResponseType, dio.Response, dio.Interceptor> {
  late final dio.Dio _dio;

  DioClient._internal([dio.BaseOptions? options]) {
    _dio = dio.Dio(options);
    addInterceptor(_DioStatus());
  }

  void close() {
    _dio.close();
  }

  @override
  bool removeInterceptor(dio.Interceptor element) {
    return interceptors.remove(element);
  }

  @override
  void addInterceptor(dio.Interceptor interceptor) {
    if (interceptors.contains(interceptor)) {
      removeInterceptor(interceptor);
    }

    interceptors.add(interceptor);
  }

  factory DioClient.createInstance([dio.BaseOptions? options]) =>
      DioClient._internal(options);

  factory DioClient() => _instance;

  static final _instance = DioClient._internal();

  @override
  Future<dio.Response> delete(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    responseType = dio.ResponseType.json,
  }) async {
    return await _dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> get(
    String url, {
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    responseType = dio.ResponseType.json,
  }) async {
    return await _dio.get(
      url,
      queryParameters: queryParameters,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> patch(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.patch(
      url,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> post(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> put(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> request(
    String url, {
    data,
    String method = 'get',
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.request(
      url,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(
        method: method,
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  List<dio.Interceptor> get interceptors => _dio.interceptors;
}
