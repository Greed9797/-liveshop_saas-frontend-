import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/live_snapshot.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Serviço HTTP centralizado com interceptors de JWT e refresh automático
class ApiService {
  static const baseUrl = 'http://127.0.0.1:3001/v1';
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'auth_user';

  static const _storage = FlutterSecureStorage();
  static late final Dio _dio;
  static bool _initialized = false;
  static Future<String?>? _refreshFuture;
  static Future<void> Function()? _onUnauthorized;

  static void setUnauthorizedHandler(Future<void> Function()? handler) {
    _onUnauthorized = handler;
  }

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
        final isAuthFailure = error.response?.statusCode == 401;
        final isAuthRoute = _isAuthRoute(error.requestOptions.path);
        final wasRetried =
            error.requestOptions.extra['retriedAfterRefresh'] == true;

        if (isAuthFailure && !isAuthRoute && !wasRetried) {
          final newToken = await _refreshAccessToken();

          if (newToken != null) {
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            options.extra['retriedAfterRefresh'] = true;

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }

          await clearTokens();
          final onUnauthorized = _onUnauthorized;
          if (onUnauthorized != null) {
            await onUnauthorized();
          }
        }

        handler.next(error);
      },
    ));
  }

  static bool _isAuthRoute(String path) {
    return path.endsWith('/auth/login') ||
        path.endsWith('/auth/refresh') ||
        path.endsWith('/auth/logout');
  }

  static Future<String?> _refreshAccessToken() {
    final pending = _refreshFuture;
    if (pending != null) return pending;

    final future = _performRefresh();
    _refreshFuture = future;
    future.whenComplete(() => _refreshFuture = null);
    return future;
  }

  static Future<String?> _performRefresh() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newToken = response.data?['access_token'] as String?;
      if (newToken == null || newToken.isEmpty) {
        return null;
      }

      await _storage.write(key: _tokenKey, value: newToken);
      return newToken;
    } catch (_) {
      return null;
    }
  }

  static String extractErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final apiMessage = data['error'] ?? data['message'];
        if (apiMessage is String && apiMessage.trim().isNotEmpty) {
          return apiMessage;
        }
      }

      if (error.response?.statusCode == 401) {
        return 'Sessão expirada. Faça login novamente.';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Tempo limite excedido ao comunicar com o servidor.';
        case DioExceptionType.connectionError:
          return 'Não foi possível conectar ao servidor.';
        case DioExceptionType.cancel:
          return 'Requisição cancelada.';
        default:
          break;
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  static Future<Response<T>> _runRequest<T>(
      Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException(extractErrorMessage(error));
    }
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _tokenKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getSavedUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      await _storage.delete(key: _userKey);
      return null;
    }
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _tokenKey);

  static Future<Response<T>> get<T>(String path,
          {Map<String, dynamic>? params}) =>
      _runRequest(() => _dio.get(path, queryParameters: params));

  static Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _runRequest(() => _dio.post(path, data: data));

  static Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _runRequest(() => _dio.patch(path, data: data));

  static Future<Response<T>> delete<T>(String path) =>
      _runRequest(() => _dio.delete(path));

  /// Opens an SSE connection to the backend and emits real-time snapshots.
  /// Uses Dio with ResponseType.stream for Flutter Web compatibility.
  /// The stream closes when the subscription is cancelled (provider disposed).
  static Stream<LiveSnapshot> streamLiveSnapshot(String liveId) async* {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return;

    late Response<ResponseBody> response;
    try {
      response = await _dio.get<ResponseBody>(
        '/lives/$liveId/stream',
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(hours: 24),
        ),
      );
    } catch (_) {
      return; // Server unavailable or live not found — stream ends silently
    }

    final buffer = StringBuffer();

    await for (final chunk
        in response.data!.stream.map<List<int>>((u) => u).transform(utf8.decoder)) {
      buffer.write(chunk);
      String pending = buffer.toString();

      while (pending.contains('\n\n')) {
        final idx = pending.indexOf('\n\n');
        final frame = pending.substring(0, idx).trim();
        pending = pending.substring(idx + 2);

        for (final line in frame.split('\n')) {
          if (!line.startsWith('data: ')) continue;
          try {
            final json =
                jsonDecode(line.substring(6)) as Map<String, dynamic>;
            yield LiveSnapshot.fromJson(json);
          } catch (_) {
            // Ignore malformed frames (heartbeats start with ':', not 'data:')
          }
        }
      }

      buffer.clear();
      buffer.write(pending);
    }
  }
}
