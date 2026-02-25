import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Centralized networking client for the Partnex app.
/// This client is configured to communicate with your local Express/MySQL backend.
class ApiClient {
  late final Dio dio;

  /// The base URL for the backend. 
  /// 
  /// IMPORTANT: When running a Flutter app on an Android Emulator, 
  /// you cannot use 'http://localhost:3000' because 'localhost' refers to the 
  /// emulator's own internal environment. 
  /// 
  /// The special IP address '10.0.2.2' is how the Android Emulator 
  /// accesses your computer's (the host machine's) local network.
  /// 
  /// If you test this on a physical device, you must change this IP to your 
  /// computer's actual local IPv4 address (e.g., http://192.168.1.5:3000).
  static const String baseUrl = 'http://10.0.2.2:3000';

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Adding Interceptors for debugging and authentication
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO(Auth): Here we will fetch the JWT token from Secure Storage 
        // and inject it into the headers before every API call.
        // String? token = await secureStorage.read(key: 'jwt_token');
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        
        if (kDebugMode) {
          print('🚀 API REQUEST: [${options.method}] ${options.uri}');
          if (options.data != null) print('📦 PAYLOAD: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ API RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('❌ API ERROR: [${e.response?.statusCode}] ${e.requestOptions.uri}');
          print('Error Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }
}
