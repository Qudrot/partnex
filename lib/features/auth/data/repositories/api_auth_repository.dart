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
      if (userData['role'] == 'sme') parsedRole = UserRole.sme;
      if (userData['role'] == 'investor') parsedRole = UserRole.investor;

      // Resilient token extraction: check multiple possible field names
      final token = response.data['token'] ??
          response.data['accessToken'] ??
          response.data['access_token'] ??
          response.data['jwt'];

      if (token != null && (token as String).isNotEmpty) {
        await _secureStorage.write(key: 'jwt_token', value: token);
        // CRITICAL: Also inject into the live Dio client immediately so
        // subsequent calls in the same session don't miss the header.
        apiClient.setToken(token);
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
      );
    } catch (e) {
      if (e is DioException) {
        // Backend may return a Map {"message":"..."} or a raw String
        final d = e.response?.data;
        final msg = (d is Map) ? d['message']?.toString() : d?.toString();
        throw Exception(msg ?? 'Failed to login');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Calls POST /auth/register on your local backend
      // We are hardcoding the role to 'sme' for this MVP onboarding path.
      final response = await apiClient.dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'role': 'sme', 
        },
      );

      // Log the full response to diagnose any token key mismatches
      if (kDebugMode) {
        print('SIGNUP RESPONSE DATA: ${response.data}');
      }

      // Same payload extraction as login
      final userData = response.data['user'];
      
      // Resilient token extraction: check multiple possible field names
      final token = response.data['token'] ??
          response.data['accessToken'] ??
          response.data['access_token'] ??
          response.data['jwt'];

      if (token != null && (token as String).isNotEmpty) {
        await _secureStorage.write(key: 'jwt_token', value: token);
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
        role: UserRole.sme,
        profilePicture: '',
      );
    } catch (e) {
      if (e is DioException) {
        final d = e.response?.data;
        final msg = (d is Map) ? d['message']?.toString() : d?.toString();
        throw Exception(msg ?? 'Failed to register');
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
      final authOptions = Options(headers: {'Authorization': 'Bearer $token'});

      // 1. Create SME Profile — send ALL required fields in one request
      final currentYear = DateTime.now().year;
      final monthlyRev = double.tryParse(data['monthlyAvgRevenue'].toString()) ?? 0.0;
      final monthlyExp = double.tryParse(data['monthlyAvgExpenses'].toString()) ?? 0.0;
      final annualRevenue = monthlyRev * 12;
      final liabilities = double.tryParse(data['totalLiabilities'].toString()) ?? 0.0;

      await apiClient.dio.post(
        '/api/sme/profile',
        data: {
          "business_name": data['businessName'],
          "industry_sector": data['industry'],
          "location": data['location'],
          "years_of_operation": data['yearsOfOperation'],
          "number_of_employees": data['numberOfEmployees'],
          "annual_revenue_year_1": currentYear - 1,
          "annual_revenue_amount_1": annualRevenue,
          "annual_revenue_year_2": currentYear,
          "annual_revenue_amount_2": annualRevenue, // Same estimate for current year
          "monthly_expenses": monthlyExp,
          "existing_liabilities": liabilities,
          "prior_funding_history": data['hasPriorFunding'] == true
              ? "Received ${data['priorFundingAmount'] ?? 0} from ${data['priorFundingSource'] ?? 'unknown'} in ${data['fundingYear'] ?? 'N/A'}"
              : "No prior funding",
        },
        options: authOptions,
      );

      // 3. Run Credibility Score
      if (kDebugMode) print('RUNNING SCORE GENERATION');

      final scoreResponse = await apiClient.dio.post(
        '/api/score/run',
        options: authOptions,
      );
      
      final scoreData = scoreResponse.data;

      // Extract risk level string and map to enum
      RiskLevel rLevel = RiskLevel.low;
      if (scoreData['risk_level'] == 'MEDIUM' || scoreData['risk_level'] == 'Medium Risk') rLevel = RiskLevel.medium;
      if (scoreData['risk_level'] == 'HIGH' || scoreData['risk_level'] == 'High Risk') rLevel = RiskLevel.high;

      return CredibilityScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        organisationId: scoreData['sme_id']?.toString() ?? 'unknown_sme',
        totalScore: (scoreData['score'] as num?)?.toDouble() ?? 0.0,
        riskLevel: rLevel,
        topContributingFactors: [],
        generalExplanation: "Score generated by ${scoreData['model_version'] ?? 'AI System'}",
        calculatedAt: DateTime.now(),
      );

    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to generate credibility score.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: Implement reading token and GET /auth/me for session persistence
    return null;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
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
      final response = await apiClient.dio.get('/api/investor/smes');
      final data = response.data;
      
      // Ensure we extract a List 
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      
      return [];
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to fetch SMEs.');
      }
      throw Exception(e.toString());
    }
  }
}
