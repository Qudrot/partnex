import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized networking client for the Partnex app.
/// Configured to communicate with the production Render backend.
class ApiClient {
  late final Dio dio;

  /// The base URL for the backend.
  static const String baseUrl = 'https://partnex-backend.onrender.com';

  /// In-memory token cache — survives hot-reloads within a single session.
  /// Populated by [setToken] immediately after login/signup.
  static String? _cachedToken;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // QueuedInterceptorsWrapper serialises interceptor execution so async ops
    // (SecureStorage reads) always complete before handler.next() is called.
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        // Priority 1: use the in-memory cached token (fastest, most reliable)
        // Priority 2: fall back to SecureStorage (survives app restarts)
        String? token = _cachedToken;
        if (token == null || token.isEmpty) {
          token = await _secureStorage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            _cachedToken = token; // warm the cache for next time
          }
        }

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('API REQUEST: [${options.method}] ${options.uri}');
          if (options.data != null) print('PAYLOAD: ${options.data}');
          print(
            'AUTH: ${options.headers['Authorization'] != null ? 'Token attached ✓' : 'No token — public route?'}',
          );
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
            'API RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}',
          );
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print(
            'API ERROR: [${e.response?.statusCode}] ${e.requestOptions.uri}',
          );
          print('Error Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  /// Sets the auth token both in memory (static cache) AND on the Dio instance.
  /// Call this immediately after a successful login or signup.
  void setToken(String token) {
    _cachedToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
    if (kDebugMode) {
      print('ApiClient.setToken: ✓ Token cached in-memory and in Dio headers.');
    }
  }

  /// Returns the current cached token (if any).
  String? getCachedToken() => _cachedToken;

  /// Static method to restore token from storage at app startup.
  /// This only sets the static cache — the Dio headers will be set
  /// when the ApiClient instance is created (via the interceptor).
  static void restoreToken(String token) {
    _cachedToken = token;
    if (kDebugMode) {
      print('ApiClient.restoreToken: ✓ Token restored to static cache.');
    }
  }

  /// Clears the token from memory and storage (call on logout).
  Future<void> clearToken() async {
    _cachedToken = null;
    dio.options.headers.remove('Authorization');
    await _secureStorage.delete(key: 'jwt_token');
    if (kDebugMode) print('ApiClient.clearToken: Token cleared.');
  }
}
