// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:content_library/content_library.dart';
import 'package:dio/dio.dart' as dio;
import 'package:html/parser.dart';

class AnrollLoginService {
  final DioClient _dioClient;
  // final HiveService _hiveService;

  const AnrollLoginService(this._dioClient);

  dio.Interceptor get getInterceptorToken => _AnrollGetTokenInterceptor();

  Future<bool> login(String email, String password) async {
    if (await checkLogin() case (
      bool result,
      int? id,
    ) when (result && id != null)) {
      return true;
    }
    try {
      final interceptor = _AnrollSaveTokenInterceptor();
      _dioClient.addInterceptor(interceptor);

      await _dioClient.post(
        "${App.ANROLL_USER_URL}/auth/login",
        data: {"email": email, "keepConnected": true, "password": password},
      );

      _dioClient.removeInterceptor(interceptor);

      return true;
    } on DioException catch (error, stack) {
      customLog(error.message, error: error, stackTrace: stack);
      return false;
    }
  }

  Future<(bool result, String message)> logout() async {
    if (await checkLogin() case (
      bool result,
      int? id,
    ) when (result && id != null)) {
      // await _hiveService.delete('anrollData_token', debug: false);
      return (true, "Deslogado com sucesso!");
    }
    return (true, "Usuario já está deslogado");
  }

  Future<String> _getBuildID() async {
    final Response responseTest = await _dioClient.get(
      App.ANROLL_URL,
      responseType: ResponseType.plain,
    );

    final element = parse(responseTest.data).querySelector('#__NEXT_DATA__');

    if (element == null) {
      throw AnrollGetIdException();
    } else {
      final map = jsonDecode(element.text);
      final buildId = map['buildId'] as String;
      return buildId;
    }
  }

  Future<(bool data, int? id)> checkLogin() async {
    // final AnrollData? anrollData = await _hiveService.load('anrollData_token', null, debug: false);

    // if (anrollData == null) return (false, null);

    // final interceptor = _AnrollCheckLoginInterceptor(anrollData);

    try {
      final buildID = await _getBuildID();
      _dioClient.addInterceptor(getInterceptorToken);
      final response = await _dioClient.get(
        "${App.ANROLL_URL}/_next/data/$buildID/conta.json",
        responseType: ResponseType.plain,
      );
      _dioClient.removeInterceptor(getInterceptorToken);
      return (
        true,
        jsonDecode(response.data)['pageProps']['data_user']['id_user'] as int,
      );
    } on DioException catch (error, stack) {
      customLog(error.message, error: error, stackTrace: stack);
      return (false, null);
    } on AnrollGetIdException catch (error, stack) {
      customLog(error.message, error: error, stackTrace: stack);
      return (false, null);
    }
  }
}

class _AnrollGetTokenInterceptor extends dio.Interceptor {
  // final HiveService _hiveService;

  _AnrollGetTokenInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers = App.HEADERS;

    // final AnrollData? anrollData = await _hiveService.load('anrollData_token', null, debug: false);

    // if (anrollData != null) {
    //   options.headers['Cookie'] = "anroll:token=${anrollData.token}";
    // }

    super.onRequest(options, handler);
  }
}

class _AnrollSaveTokenInterceptor extends dio.Interceptor {
  // final HiveService _hiveService;

  _AnrollSaveTokenInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers = App.HEADERS;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // if (response.statusCode == 200) {
    //   _hiveService.save('anrollData_token', AnrollData.fromMap(response.data['data']), debug: false);
    // }

    super.onResponse(response, handler);
  }
}

class AnrollData {
  final String token;
  final String? refreshToken;
  final String email;

  AnrollData({required this.token, this.refreshToken, required this.email});

  Map<dynamic, dynamic> get toMap {
    return <String, dynamic>{
      'token': token,
      'refreshToken': refreshToken,
      'email': email,
    };
  }

  factory AnrollData.fromMap(Map<dynamic, dynamic> map) {
    return AnrollData(
      token: map['token'] as String,
      refreshToken: map['refreshToken'] != null
          ? map['refreshToken'] as String
          : null,
      email: map['email'] as String,
    );
  }
}
