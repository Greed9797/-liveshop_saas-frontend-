import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço HTTP centralizado com interceptors de JWT e refresh automático
class ApiService {
  static const baseUrl = 'http://192.168.1.5:3001/v1';
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static const _storage = FlutterSecureStorage();
  static late final Dio _dio;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 → tenta refresh automático
        if (error.response?.statusCode == 401) {
          final refreshToken = await _storage.read(key: _refreshKey);
          if (refreshToken != null) {
            try {
              final resp = await Dio().post(
                '$baseUrl/auth/refresh',
                data: {'refresh_token': refreshToken},
              );
              final newToken = resp.data['access_token'] as String;
              await _storage.write(key: _tokenKey, value: newToken);

              // Retry original request com novo token
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              final retryResp = await _dio.fetch(opts);
              return handler.resolve(retryResp);
            } catch (_) {
              await clearTokens();
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _tokenKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  static Future<String?> getAccessToken() => _storage.read(key: _tokenKey);

  static Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  static Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  static Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  static Future<Response<T>> delete<T>(String path) =>
      _dio.delete(path);
}
