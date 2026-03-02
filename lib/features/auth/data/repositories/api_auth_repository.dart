import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:partnex/core/network/api_client.dart';
import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';

/// The official repository that connects your Flutter UI to your
/// local Express.js & MySQL backend.
class ApiAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiAuthRepository({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      // Calls POST /auth/login on your local backend
      final response = await apiClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Your backend returns: { user: { id, email, role }, token: "..." }
      // Log the full response to diagnose any token key mismatches
      if (kDebugMode) {
        print('LOGIN RESPONSE DATA: ${response.data}');
      }

      final userData = response.data['user'];
      
      // We map the string role from the backend into our Flutter Enum
      UserRole parsedRole = UserRole.sme; // Default fallback
      final lowerRole = userData['role']?.toString().toLowerCase();
      if (lowerRole == 'sme') parsedRole = UserRole.sme;
      if (lowerRole == 'investor') parsedRole = UserRole.investor;

      // Parse profile completion
      bool isProfileCompleted = false;
      if (userData.containsKey('has_score')) {
          isProfileCompleted = userData['has_score'] == true || userData['has_score'] == 1;
      } else if (userData.containsKey('profile_completed')) {
          isProfileCompleted = userData['profile_completed'] == true || userData['profile_completed'] == 1;
      }

      // Resilient token extraction: check multiple possible field names
      final token = response.data['token'] ??
          response.data['accessToken'] ??
          response.data['access_token'] ??
          response.data['jwt'];

      if (token != null && (token as String).isNotEmpty) {
        await _secureStorage.write(key: 'jwt_token', value: token);
        await _secureStorage.write(key: 'user_role', value: parsedRole.name);
        // CRITICAL: Also inject into the live Dio client immediately so
        // subsequent calls in the same session don't miss the header.
        apiClient.setToken(token);

        // Fallback check: if the login payload skipped the flag, manually check the score endpoint
        if (parsedRole == UserRole.sme && !isProfileCompleted) {
          try {
            final score = await getMyScore(); // getMyScore calls POST /api/score/run and throws if not found
            isProfileCompleted = true;
            if (kDebugMode) print('LOGIN RECOVERY: Found existing SME score, updating flag.');
          } catch (_) {}
        }

        await _secureStorage.write(key: 'profile_completed', value: isProfileCompleted.toString());
        if (kDebugMode) print('TOKEN STORED + INJECTED: ${token.substring(0, 20)}...');
      } else {
        if (kDebugMode) print('WARNING: No token found in login response! Keys: ${response.data.keys}');
      }

      return UserModel(
        id: userData['id'].toString(), // Backend returns int, UserModel expects String
        email: userData['email'],
        name: 'SME user', // Your backend 'users' table doesn't have 'name', you may want to add it!
        role: parsedRole,
        profilePicture: '', 
        profileCompleted: isProfileCompleted,
      );
    } catch (e) {
      if (e is DioException) {
        // Backend may return a Map {"message":"..."} or a raw String
        final d = e.response?.data;
        final msg = (d is Map) ? d['message']?.toString() : d?.toString();
        
        final lowerMsg = msg?.toLowerCase() ?? '';
        if (lowerMsg.contains('invalid credential') || lowerMsg.contains('incorrect password') || e.response?.statusCode == 401) {
           throw Exception('The email or password you entered is incorrect. Double-check and try again.');
        } else if (lowerMsg.contains('not found') || lowerMsg.contains('no user') || lowerMsg.contains('unregistered') || e.response?.statusCode == 404) {
           throw Exception('Account not found. It looks like you are new here!|REGISTRATION_REDIRECT');
        }
        
        if (msg == null && e.type != DioExceptionType.badResponse) {
           throw Exception('Network error: ${e.message}. Please check your internet connection.');
        }
        
        throw Exception(msg ?? 'Failed to sign in. Please try again.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Calls POST /auth/register on your local backend
      final response = await apiClient.dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'role': role, 
        },
      );

      // Log the full response to diagnose any token key mismatches
      if (kDebugMode) {
        print('SIGNUP RESPONSE DATA: ${response.data}');
      }

      // Same payload extraction as login
      final userData = response.data['user'];
      
      // Parse role from backend (or fallback to what was requested)
      UserRole parsedRole = role.toLowerCase() == 'investor' ? UserRole.investor : UserRole.sme;
      final lowerBackendRole = userData['role']?.toString().toLowerCase();
      if (lowerBackendRole == 'sme') parsedRole = UserRole.sme;
      if (lowerBackendRole == 'investor') parsedRole = UserRole.investor;

      // Resilient token extraction: check multiple possible field names
      final token = response.data['token'] ??
          response.data['accessToken'] ??
          response.data['access_token'] ??
          response.data['jwt'];

      if (token != null && (token as String).isNotEmpty) {
        await _secureStorage.write(key: 'jwt_token', value: token);
        await _secureStorage.write(key: 'user_role', value: parsedRole.name);
        await _secureStorage.write(key: 'profile_completed', value: 'false');
        // CRITICAL: Also inject into the live Dio client immediately.
        apiClient.setToken(token);
        if (kDebugMode) print('TOKEN STORED + INJECTED: ${token.substring(0, 20)}...');
      } else {
        if (kDebugMode) print('WARNING: No token found in signup response! Keys: ${response.data.keys}');
      }

      return UserModel(
        id: userData['id'].toString(),
        email: userData['email'],
        name: name, 
        role: parsedRole,
        profilePicture: '', 
        profileCompleted: false,
      );
    } catch (e) {
      if (e is DioException) {
        final d = e.response?.data;
        final msg = (d is Map) ? d['message']?.toString() : d?.toString();
        
        final lowerMsg = msg?.toLowerCase() ?? '';
        if (lowerMsg.contains('already exist') || lowerMsg.contains('duplicate') || e.response?.statusCode == 409) {
           throw Exception('An account with this email already exists. Try logging in instead.');
        }
        
        if (msg == null && e.type != DioExceptionType.badResponse) {
           throw Exception('Network error: ${e.message}. Please check your internet connection.');
        }

        throw Exception(msg ?? 'Failed to register. Please try again.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<CredibilityScore> submitSmeProfile(Map<String, dynamic> data) async {
    try {
      // Resolve the token: prefer the static in-memory cache
      // (set at login/signup), fall back to SecureStorage (app restarts).
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }

      if (kDebugMode) {
        print('submitSmeProfile token resolved: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Session expired. Please log in again to continue.');
      }

      // Build explicit auth options for every protected request.
      // This is the most reliable approach — no interceptor dependency.
      final authOptions = Options(
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      );

      final Map<String, dynamic> payload = {
        "business_name": data['businessName'],
        "industry_sector": data['industry'],
        "location": data['location'],
        "years_of_operation": data['yearsOfOperation'],
        "number_of_employees": data['numberOfEmployees'],
        "annual_revenue_year_1": data['annualRevenueYear1'],
        "annual_revenue_amount_1": data['annualRevenueAmount1'],
        "annual_revenue_year_2": data['annualRevenueYear2'],
        "annual_revenue_amount_2": data['annualRevenueAmount2'],
        "monthly_expenses": data['monthlyAvgExpenses'],
        "existing_liabilities": data['totalLiabilities'],
        "prior_funding_history": data['hasPriorFunding'] == true
            ? "Received ${data['priorFundingAmount'] ?? 0} from ${data['priorFundingSource'] ?? 'unknown'} in ${data['fundingYear'] ?? 'N/A'}"
            : "No prior funding",
        "repayment_history": data['repaymentHistory'] ?? 'N/A',
      };

      if (data['annualRevenueYear3'] != null) {
        payload["annual_revenue_year_3"] = data['annualRevenueYear3'];
        payload["annual_revenue_amount_3"] = data['annualRevenueAmount3'] ?? 0;
      }

      if (data['monthlyAvgRevenue'] != null) {
        payload["monthly_revenue"] = data['monthlyAvgRevenue'];
      }

      try {
        await apiClient.dio.post(
          '/api/sme/profile',
          data: payload,
          options: authOptions,
        );
      } catch (e) {
        if (e is DioException) {
          final msg = (e.response?.data['message'] ?? e.response?.data['error'] ?? '').toString().toLowerCase();
          if (msg.contains('already exists')) {
            if (kDebugMode) print('Profile already exists, proceeding to score generation...');
            // In a complete implementation, you might want to call PUT here to update the profile instead.
            // For now, we catch the exception and proceed so the user can get their score.
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      // 3. Run Credibility Score
      if (kDebugMode) print('RUNNING SCORE GENERATION');

      final scoreResponse = await apiClient.dio.post(
        '/api/score/run',
        options: authOptions,
      );
      
      final scoreData = scoreResponse.data;
      if (kDebugMode) {
        print('Model Version generated: ${scoreData['model_version']}');
      }

      // Extract risk level string and map to enum
      RiskLevel rLevel = RiskLevel.low;
      if (scoreData['risk_level'] == 'MEDIUM' || scoreData['risk_level'] == 'Medium Risk') rLevel = RiskLevel.medium;
      if (scoreData['risk_level'] == 'HIGH' || scoreData['risk_level'] == 'High Risk') rLevel = RiskLevel.high;

      // Mark profile as completed locally
      await _secureStorage.write(key: 'profile_completed', value: 'true');

      return CredibilityScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        organisationId: scoreData['sme_id']?.toString() ?? 'unknown_sme',
        totalScore: (scoreData['score'] as num?)?.toDouble() ?? 0.0,
        riskLevel: rLevel,
        topContributingFactors: [],
        generalExplanation: scoreData['explanation_json']?.toString(),
        modelVersion: scoreData['model_version']?.toString() ?? 'fallback-v1',
        calculatedAt: DateTime.now(),
      );

    } catch (e) {
      if (kDebugMode) {
        print('Score Generation Error in submitSmeProfile: $e');
        if (e is DioException) {
          print('DioException response data: ${e.response?.data}');
        }
      }
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to generate credibility score.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> submitInvestorProfile(Map<String, dynamic> data) async {
    try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Session expired. Please log in again.');
      }


      // Mocking the Backend Profile Save to unblock the UI
      // In the future, this should be an apiClient.dio.post('/api/investor/profile')
      if (kDebugMode) {
        print('Mocking investor profile submission via secure storage: $data');
      }

      // Save locally to simulate persistence
      await _secureStorage.write(key: 'investor_type', value: data['role']);
      await _secureStorage.write(key: 'preferred_sectors', value: jsonEncode(data['sectors']));
      await _secureStorage.write(key: 'typical_ticket_size', value: data['ticketSize']);
      
      // Update local role to investor
      await _secureStorage.write(key: 'user_role', value: 'investor');
      await _secureStorage.write(key: 'profile_completed', value: 'true');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to save investor profile.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return null;

      // Inject token into API client so auto-login restores session for future requests
      apiClient.setToken(token);

      final roleStr = await _secureStorage.read(key: 'user_role');
      UserRole parsedRole = UserRole.sme;
      if (roleStr != null && roleStr.toLowerCase() == 'investor') {
        parsedRole = UserRole.investor;
      }

      final profileCompletedStr = await _secureStorage.read(key: 'profile_completed');
      final isProfileCompleted = profileCompletedStr == 'true';

      // We don't have personal data stored locally by default from just login/signup 
      // besides the token, but we can reconstruct a basic UserModel to satisfy the AuthBloc's router.
      // Ideally this would make a GET /api/auth/me call, but returning this avoids an extra network hop blocking app startup.
      return UserModel(
        id: "cached-user",
        email: "user@partnex",
        name: "User",
        role: parsedRole,
        profilePicture: "",
        profileCompleted: isProfileCompleted,
      );
    } catch (e) {
      if (kDebugMode) print('Error retrieving user session: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteAll(); // Clear everything: token, role, completion flags, etc.
    apiClient.setToken('');
  }

  @override
  Future<Map<String, dynamic>> getMySmeProfile() async {
    try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }
      if (token == null || token.isEmpty) {
        throw Exception('Session expired.');
      }

      final authOptions = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await apiClient.dio.get('/api/sme/profile', options: authOptions);
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('profile')) {
          return data['profile'] as Map<String, dynamic>;
        }
        return data; 
      }
      return {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return {}; // Return empty if profile endpoint doesn't exist yet or is forbidden
      }
      throw Exception('Failed to fetch SME profile: $e');
    } catch (e) {
      throw Exception('Failed to fetch SME profile: $e');
    }
  }

  @override
  Future<CredibilityScore> getMyScore() async {
     try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }
      final authOptions = Options(
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      );

      // We use /score/run to compute/fetch the latest score per API docs
      final scoreResponse = await apiClient.dio.post('/api/score/run', options: authOptions);
      final scoreData = scoreResponse.data;
      if (kDebugMode) {
        print('Model Version retrieved: ${scoreData['model_version']}');
      }

      RiskLevel rLevel = RiskLevel.low;
      if (scoreData['risk_level'] == 'MEDIUM' || scoreData['risk_level'] == 'Medium Risk') rLevel = RiskLevel.medium;
      if (scoreData['risk_level'] == 'HIGH' || scoreData['risk_level'] == 'High Risk') rLevel = RiskLevel.high;

      // Extract JSON explanation if present
      final explanationData = scoreData['explanation_json'];
      List<String> topFactors = [];
      if (explanationData != null && explanationData is Map) {
         // Try to pull drivers if the backend AI returns them in a specific format
      }

      return CredibilityScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        organisationId: scoreData['sme_id']?.toString() ?? 'unknown_sme',
        totalScore: (scoreData['score'] as num?)?.toDouble() ?? 0.0,
        riskLevel: rLevel,
        topContributingFactors: topFactors,
        generalExplanation: scoreData['explanation_json']?.toString(),
        modelVersion: scoreData['model_version']?.toString() ?? 'fallback-v1',
        calculatedAt: DateTime.now(),
      );
     } catch(e) {
       if (kDebugMode) {
         print('Score Generation Error: $e');
         if (e is DioException) {
           print('DioException response data: ${e.response?.data}');
         }
       }
       throw Exception('Failed to fetch credibility score.');
     }
  }

  @override
  Future<void> uploadStatementOfAccount(File file) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      await apiClient.dio.post(
        '/api/soa/upload',
        data: formData,
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to upload statement of account.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorSmes() async {
    try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }
      final authOptions = Options(headers: {'Authorization': 'Bearer $token'});

      final response = await apiClient.dio.get('/api/investor/smes', options: authOptions);
      final data = response.data;
      
      if (data is List) {
        return List<Map<String, dynamic>>.from(data.map((x) => Map<String, dynamic>.from(x)));
      } else if (data is Map) {
        if (data.containsKey('data') && data['data'] is List) {
           return List<Map<String, dynamic>>.from((data['data'] as List).map((x) => Map<String, dynamic>.from(x)));
        } else if (data.containsKey('smes') && data['smes'] is List) {
           return List<Map<String, dynamic>>.from((data['smes'] as List).map((x) => Map<String, dynamic>.from(x)));
        }
      }
      
      return [];
    } catch (e) {
      if (e is DioException) {
        final errData = e.response?.data;
        String errMsg = 'Failed to fetch SMEs. HTTP ${e.response?.statusCode}';
        if (errData is Map && (errData.containsKey('message') || errData.containsKey('error'))) {
           errMsg = errData['message'] ?? errData['error'];
        }
        if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
          throw Exception('Forbidden: $errMsg');
        }
        throw Exception(errMsg);
      }
      throw Exception(e.toString());
    }
  }
}
