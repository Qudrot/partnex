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
      final response = await apiClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (kDebugMode) {
        print('LOGIN RESPONSE DATA: ${response.data}');
      }

      final userData = response.data['user'];
      
      UserRole parsedRole = UserRole.sme; 
      final lowerRole = userData['role']?.toString().toLowerCase();
      if (lowerRole == 'sme') parsedRole = UserRole.sme;
      if (lowerRole == 'investor') parsedRole = UserRole.investor;

      bool isProfileCompleted = false;
      if (userData.containsKey('has_score')) {
          isProfileCompleted = userData['has_score'] == true || userData['has_score'] == 1;
      } else if (userData.containsKey('profile_completed')) {
          isProfileCompleted = userData['profile_completed'] == true || userData['profile_completed'] == 1;
      }

      final token = response.data['token'] ??
          response.data['accessToken'] ??
          response.data['access_token'] ??
          response.data['jwt'];

      if (token != null && (token as String).isNotEmpty) {
        await _secureStorage.delete(key: 'cached_credibility_score');
        await _secureStorage.delete(key: 'cached_sme_profile');
        await _secureStorage.delete(key: 'cached_investor_profile');

        await _secureStorage.write(key: 'jwt_token', value: token);
        await _secureStorage.write(key: 'user_role', value: parsedRole.name);
        apiClient.setToken(token);

        if (!isProfileCompleted && parsedRole == UserRole.sme) {
          try {
            await getMyScore();
            isProfileCompleted = true;
            if (kDebugMode) print('Login: Score fetched successfully. Profile is complete.');
          } catch (_) {
            try {
              final profile = await getMySmeProfile();
              isProfileCompleted = profile.isNotEmpty;
            } catch (_) {}
          }
        }

        else if (!isProfileCompleted && parsedRole == UserRole.investor) {
          try {
            final profile = await getMyInvestorProfile();
            isProfileCompleted = profile.isNotEmpty;
            if (kDebugMode && isProfileCompleted) print('Login: Investor profile fetched successfully.');
          } catch (_) {}
        }

        await _secureStorage.write(key: 'profile_completed', value: isProfileCompleted.toString());
      }

      return UserModel(
        id: userData['id'].toString(),
        email: userData['email'],
        name: userData['name'] ?? 'SME user',
        role: parsedRole,
        profilePicture: userData['profile_picture'] ?? '', 
        profileCompleted: isProfileCompleted,
      );
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _handleDioError(dynamic e) {
    if (e is DioException) {
      final d = e.response?.data;
      String? msg;
      
      if (d is Map) {
        msg = d['message']?.toString() ?? d['error']?.toString();
      } else if (d is String && d.contains('<body')) {
        final match = RegExp(r'<pre>(.*?)</pre>').firstMatch(d);
        msg = match?.group(1) ?? 'Service temporarily unavailable (404/500)';
      } else {
        msg = d?.toString();
      }

      final lowerMsg = msg?.toLowerCase() ?? '';
      final statusCode = e.response?.statusCode;

      if (lowerMsg.contains('invalid credential') || statusCode == 401) {
        return Exception('Incorrect email or password. Please try again.');
      } 
      if (lowerMsg.contains('not found') || statusCode == 404) {
        if (e.requestOptions.path.contains('login')) {
          return Exception('Account not found. It looks like you are new here!|REGISTRATION_REDIRECT');
        }
        return Exception('The requested resource was not found.');
      }
      if (statusCode == 409 || lowerMsg.contains('already exists')) {
        return Exception('This email is already registered. Try logging in instead.');
      }

      return Exception(msg ?? 'Network error. Please check your connection.');
    }
    return e;
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
    required String role,
    String? position,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          'position': position,
        },
      );

      if (kDebugMode) {
        print('SIGNUP RESPONSE DATA: ${response.data}');
      }

      final userData = response.data['user'];
      
      UserRole parsedRole = role.toLowerCase() == 'investor' ? UserRole.investor : UserRole.sme;
      final lowerBackendRole = userData['role']?.toString().toLowerCase();
      if (lowerBackendRole == 'sme') parsedRole = UserRole.sme;
      if (lowerBackendRole == 'investor') parsedRole = UserRole.investor;

      final token = response.data['token'] ??
          response.data['accessToken'] ??
          response.data['access_token'] ??
          response.data['jwt'];

      if (token != null && (token as String).isNotEmpty) {
        await _secureStorage.write(key: 'jwt_token', value: token);
        await _secureStorage.write(key: 'user_role', value: parsedRole.name);
        await _secureStorage.write(key: 'profile_completed', value: 'false');
        apiClient.setToken(token);
      }

      return UserModel(
        id: userData['id'].toString(),
        email: userData['email'] ?? email,
        name: userData['name'] ?? name, 
        role: parsedRole,
        profilePicture: userData['profile_picture'] ?? '', 
        profileCompleted: false,
        position: userData['position'] ?? position,
      );
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CredibilityScore> submitSmeProfile(Map<String, dynamic> data, {bool shouldGenerateScore = true}) async {
    try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Your session has expired. Please sign in again to continue.');
      }

      final authOptions = Options(
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 180),
        sendTimeout: const Duration(seconds: 180),
      );

      final Map<String, dynamic> payload = {
        "business_name": data['businessName'],
        "industry_sector": data['industry'],
        "location": data['location'],
        "years_of_operation": data['yearsOfOperation'],
        "number_of_employees": data['numberOfEmployees'],
        "monthly_expenses": data['monthlyAvgExpenses'],
        "existing_liabilities": data['totalLiabilities'],
        "prior_funding_history": data['hasPriorFunding'] == true
            ? "Received ${data['priorFundingAmount'] ?? 0} from ${data['priorFundingSource'] ?? 'unknown'} in ${data['fundingYear'] ?? 'N/A'}"
            : "No prior funding",
        "repayment_history": data['repaymentHistory'] ?? 'N/A',
        "website": data['websiteUrl'],
        "whatsapp": data['whatsappNumber'],
        "linkedin": data['linkedinUrl'],
        "twitter": data['twitterHandle'],
        "bio": data['bio'],
        "contact_person_name": data['contactName'],
        "contact_person_title": data['contactPosition'],
        "email": data['email'],
        "phone_number": data['phoneNumber'],
        "allow_sharing": data['allowSharing'] == false ? 0 : 1,
        "data_source": data['dataSource'],
      };


      List<Map<String, dynamic>> revData = [];
      if (data['annualRevenueYear1'] != null) {
        revData.add({'year': data['annualRevenueYear1'], 'amount': data['annualRevenueAmount1'] ?? 0});
      }
      if (data['annualRevenueYear2'] != null) {
        revData.add({'year': data['annualRevenueYear2'], 'amount': data['annualRevenueAmount2'] ?? 0});
      }
      if (data['annualRevenueYear3'] != null && (data['annualRevenueAmount3'] ?? 0) > 0) {
        revData.add({'year': data['annualRevenueYear3'], 'amount': data['annualRevenueAmount3'] ?? 0});
      }

      // THE FIX: Swap 'b' and 'a' so the newest year is always year_1
revData.sort((a, b) => (b['year'] as int).compareTo(a['year'] as int));

      if (revData.isNotEmpty) {
        payload["annual_revenue_year_1"] = revData[0]['year'];
        payload["annual_revenue_amount_1"] = revData[0]['amount'];
      }
      if (revData.length > 1) {
        payload["annual_revenue_year_2"] = revData[1]['year'];
        payload["annual_revenue_amount_2"] = revData[1]['amount'];
      }
      if (revData.length > 2) {
        payload["annual_revenue_year_3"] = revData[2]['year'];
        payload["annual_revenue_amount_3"] = revData[2]['amount'];
      }

      if (data['monthlyAvgRevenue'] != null) {
        payload["monthly_revenue"] = data['monthlyAvgRevenue'];
      }

      try {
        await apiClient.dio.post('/api/sme/profile', data: payload, options: authOptions);
      } catch (e) {
        if (e is DioException) {
          final statusCode = e.response?.statusCode;
          final msg = (e.response?.data is Map) 
              ? (e.response?.data['message'] ?? e.response?.data['error'] ?? '').toString().toLowerCase()
              : e.response?.data?.toString().toLowerCase() ?? '';
          
          if (statusCode == 409 || statusCode == 400 || msg.contains('already exists')) {
            try {
              await apiClient.dio.put('/api/sme/profile', data: payload, options: authOptions);
            } catch (putError) {
              if (putError is DioException && putError.response?.statusCode == 404) {
                 try {
                   await apiClient.dio.patch('/api/sme/profile', data: payload, options: authOptions);
                 } catch (patchError) {}
              }
            }
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      try {
        await _secureStorage.write(key: 'cached_sme_profile', value: jsonEncode(data));
      } catch (_) {}

      if (!shouldGenerateScore) {
        final existingScore = await getMyScore();
        await _secureStorage.write(key: 'cached_credibility_score', value: jsonEncode(existingScore.toJson()));
        return existingScore;
      }

      final scoreResponse = await apiClient.dio.post('/api/score/run', data: payload, options: authOptions);
      final scoreData = scoreResponse.data;

      RiskLevel rLevel = RiskLevel.low;
      if (scoreData['risk_level'] == 'MEDIUM' || scoreData['risk_level'] == 'Medium Risk') rLevel = RiskLevel.medium;
      if (scoreData['risk_level'] == 'HIGH' || scoreData['risk_level'] == 'High Risk') rLevel = RiskLevel.high;

      await _secureStorage.write(key: 'profile_completed', value: 'true');

      final explanationData = scoreData['explanation'];
      String? explanationText;
      if (explanationData is Map) {
        explanationText = explanationData['note']?.toString();
      } else {
        explanationText = explanationData?.toString();
      }
   
      double extractScoreSafe(Map data) {
        final knownKeys = ['score', 'credibility_score', 'currentCredibilityScore', 'credibilityScore', 'current_credibility_score', 'totalScore', 'total_score', 'final_score', 'overall_score'];
        for (var key in knownKeys) {
          if (data[key] != null) {
            if (data[key] is num) return (data[key] as num).toDouble();
            final parsed = double.tryParse(data[key].toString());
            if (parsed != null) return parsed;
          }
        }
        for (var entry in data.entries) {
          if (entry.key.toString().toLowerCase().contains('score')) {
            if (entry.value is num) return (entry.value as num).toDouble();
            final parsed = double.tryParse(entry.value.toString());
            if (parsed != null) return parsed;
          }
        }
        return 0.0;
      }
      
      final newScore = CredibilityScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        organisationId: scoreData['sme_id']?.toString() ?? 'unknown_sme',
        totalScore: extractScoreSafe(scoreData is Map ? scoreData : {}),
        riskLevel: rLevel,
        topContributingFactors: [],
        generalExplanation: explanationText,
        modelVersion: scoreData['model_version']?.toString() ?? 'fallback-v1',
        calculatedAt: DateTime.now(),
        impactScore: (scoreData['explanation']?['model_inputs']?['impact_score'] as num?)?.toDouble() 
                  ?? (scoreData['impact_score'] as num?)?.toDouble() 
                  ?? 0.7,
      );

      await _secureStorage.write(key: 'cached_credibility_score', value: jsonEncode(newScore.toJson()));
      return newScore;

    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String errorMessage = 'Failed to generate credibility score.';
        if (data is Map) {
          errorMessage = data['message'] ?? data['error'] ?? errorMessage;
        } else if (data != null) {
          errorMessage = data.toString();
        }
        throw Exception(errorMessage);
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
        throw Exception('Your session has expired. Please sign in again to continue.');
      }

      final authOptions = Options(headers: {'Authorization': 'Bearer $token'});
      final currentUser = await getCurrentUser();
      final realName = data['name'] ?? data['fullName'] ?? currentUser?.name ?? "Investor";
      
      final Map<String, dynamic> payload = {
        "full_name": realName, 
        "organization": data['company'] ?? data['organization'],
        "location": data['location'] ?? "Not explicitly listed",
        "investor_type": data['investorType'] ?? data['role'],
        "preferred_sectors": data['sectors'],
        "typical_ticket_size": data['investmentRange'] ?? data['ticketSize']
      };

      await apiClient.dio.post('/api/investor/profile', data: payload, options: authOptions);

      await _secureStorage.write(key: 'investor_type', value: data['role']);
      await _secureStorage.write(key: 'preferred_sectors', value: jsonEncode(data['sectors']));
      await _secureStorage.write(key: 'typical_ticket_size', value: data['ticketSize']);
      await _secureStorage.write(key: 'user_role', value: 'investor');
      await _secureStorage.write(key: 'profile_completed', value: 'true');
      try {
        await _secureStorage.write(key: 'cached_investor_profile', value: jsonEncode(data));
      } catch (_) {}
      
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'We couldn\'t save your profile preferences. Please try again.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return null;

      apiClient.setToken(token);

      final roleStr = await _secureStorage.read(key: 'user_role');
      UserRole parsedRole = UserRole.sme;
      if (roleStr != null && roleStr.toLowerCase() == 'investor') {
        parsedRole = UserRole.investor;
      }

      try {
        if (parsedRole == UserRole.sme) {
          final profileMap = await getMySmeProfile();
          if (profileMap.isNotEmpty) {
            return UserModel(
              id: profileMap['user_id']?.toString() ?? profileMap['id']?.toString() ?? "cached-sme",
              email: profileMap['email']?.toString() ?? "user@partnex",
              name: profileMap['business_name']?.toString() ?? profileMap['name']?.toString() ?? "SME User",
              role: parsedRole,
              profilePicture: profileMap['logo_url']?.toString() ?? "",
              profileCompleted: true,
            );
          }
        } else {
          final profileMap = await getMyInvestorProfile();
          if (profileMap.isNotEmpty) {
             return UserModel(
              id: profileMap['user_id']?.toString() ?? profileMap['id']?.toString() ?? "cached-investor",
              email: profileMap['email']?.toString() ?? "investor@partnex",
              name: profileMap['full_name']?.toString() ?? profileMap['name']?.toString() ?? "Investor",
              role: parsedRole,
              profilePicture: profileMap['avatar_url']?.toString() ?? "",
              profileCompleted: true,
              investorType: profileMap['role'] ?? profileMap['investorType'] ?? profileMap['investor_type'],
              company: profileMap['company'] ?? profileMap['organization'],
              investmentRange: profileMap['ticketSize'] ?? profileMap['typical_ticket_size'] ?? profileMap['investmentRange'],
              sectors: profileMap['sectors'] != null 
                  ? List<String>.from(profileMap['sectors']) 
                  : (profileMap['preferred_sectors'] != null ? List<String>.from(profileMap['preferred_sectors']) : null),
            );
          }
        }
      } catch (e) {}

      final profileCompletedStr = await _secureStorage.read(key: 'profile_completed');
      final isProfileCompleted = profileCompletedStr == 'true';

      return UserModel(
        id: "cached-session",
        email: "user@partnex",
        name: "User",
        role: parsedRole,
        profilePicture: "",
        profileCompleted: isProfileCompleted,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteAll(); 
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
        throw Exception('Your session has expired. Please sign in again to continue.');
      }

      final authOptions = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await apiClient.dio.get('/api/sme/me', options: authOptions);
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('sme')) {
          return data['sme'] as Map<String, dynamic>;
        }
        if (data.containsKey('profile')) {
          return data['profile'] as Map<String, dynamic>;
        }
        return data; 
      }
      return {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        try {
          final cachedStr = await _secureStorage.read(key: 'cached_sme_profile');
          if (cachedStr != null && cachedStr.isNotEmpty) {
            return jsonDecode(cachedStr) as Map<String, dynamic>;
          }
        } catch (_) {}
        return {}; 
      }
      throw Exception('Unable to load business details. Please check your connection and try again.');
    } catch (e) {
      throw Exception('Unable to load business details. Please check your connection and try again.');
    }
  }

  @override
  Future<CredibilityScore> getMyScore() async {
    try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }
      if (token == null || token.isEmpty) {
        // Try returning cached score before throwing
        try {
          final cachedStr = await _secureStorage.read(key: 'cached_credibility_score');
          if (cachedStr != null && cachedStr.isNotEmpty) {
            return CredibilityScore.fromJson(jsonDecode(cachedStr));
          }
        } catch (_) {}
        throw Exception('Your session has expired. Please sign in again to continue.');
      }
      final authOptions = Options(
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      );

      final response = await apiClient.dio.get('/api/sme/me', options: authOptions);
      final responseData = response.data is Map ? response.data : {};
      
      final smeData = responseData['sme'] ?? responseData['profile'] ?? responseData;
      final Map scoreMap = smeData['credibility'] is Map ? smeData['credibility'] : smeData;

      RiskLevel rLevel = RiskLevel.low;
      final riskStr = (scoreMap['risk_level'] ?? scoreMap['riskLevel'])?.toString().toUpperCase();
      if (riskStr == 'MEDIUM' || riskStr == 'MEDIUM RISK') rLevel = RiskLevel.medium;
      if (riskStr == 'HIGH' || riskStr == 'HIGH RISK') rLevel = RiskLevel.high;

      double extractScoreSafe(Map data) {
        final knownKeys = ['score', 'credibility_score', 'currentCredibilityScore', 'credibilityScore', 'totalScore', 'total_score'];
        for (var key in knownKeys) {
          if (data[key] != null) {
            if (data[key] is num) return (data[key] as num).toDouble();
            final parsed = double.tryParse(data[key].toString());
            if (parsed != null) return parsed;
          }
        }
        for (var entry in data.entries) {
          final lowKey = entry.key.toString().toLowerCase();
          if (lowKey.contains('score')) {
             if (lowKey == 'impact_score' || lowKey == 'impactscore') continue;
             if (entry.value is num) return (entry.value as num).toDouble();
             final parsed = double.tryParse(entry.value.toString());
             if (parsed != null) return parsed;
          }
        }
        return 0.0;
      }

      final double extractedScore = extractScoreSafe(scoreMap);

      if (kDebugMode && extractedScore == 0.0 && scoreMap.isNotEmpty) {
          print('WARNING: Credibility score extraction found 0.0 but map is NOT empty. Keys: ${scoreMap.keys.toList()}');
      }

      final score = CredibilityScore(
        id: scoreMap['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        organisationId: smeData['sme_id']?.toString() ?? smeData['id']?.toString() ?? 'unknown_sme',
        totalScore: extractedScore,
        riskLevel: rLevel,
        topContributingFactors: [],
        generalExplanation: scoreMap['explanation_json']?.toString() ?? scoreMap['explanation']?.toString(),
        modelVersion: scoreMap['model_version']?.toString() ?? 'v-cache',
        calculatedAt: DateTime.tryParse(scoreMap['created_at']?.toString() ?? '') ?? DateTime.now(),
        impactScore: (scoreMap['explanation']?['model_inputs']?['impact_score'] as num?)?.toDouble() 
                  ?? (scoreMap['impact_score'] as num?)?.toDouble() 
                  ?? 0.7,
      );

      if (score.totalScore == 0) {
        try {
          final profResp = await apiClient.dio.get('/api/sme/profile', options: authOptions);
          final profData = profResp.data is Map ? profResp.data : {};
          final smePart = profData['sme'] ?? profData['profile'] ?? profData;
          final sVal = extractScoreSafe(smePart['credibility'] is Map ? smePart['credibility'] : smePart);
          if (sVal > 0) {
             return score.copyWith(totalScore: sVal);
          }
        } catch (_) {}
      }

      try {
        final cachedStr = await _secureStorage.read(key: 'cached_credibility_score');
        if (cachedStr != null && cachedStr.isNotEmpty) {
          final cached = CredibilityScore.fromJson(jsonDecode(cachedStr));
          if (score.totalScore == 0 && cached.totalScore > 0) {
            return cached;
          }
        }
      } catch (e) {}

      if (score.totalScore > 0) {
        await _secureStorage.write(key: 'cached_credibility_score', value: jsonEncode(score.toJson()));
      }
      
      return score;
      
    } catch(e) {
      try {
        final cachedScore = await _secureStorage.read(key: 'cached_credibility_score');
        if (cachedScore != null && cachedScore.isNotEmpty) {
          return CredibilityScore.fromJson(jsonDecode(cachedScore));
        }
      } catch (_) {}

      throw Exception('We couldn\'t load your credibility score at this time. Please try again.');
    }
  }

  @override
  Future<void> uploadStatementOfAccount(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      await apiClient.dio.post('/api/soa/upload', data: formData);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? e.response?.data['error'] ?? 'We couldn\'t upload your statement. Please check the file format and try again.');
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
      if (token == null || token.isEmpty) {
        throw Exception('Your session has expired. Please sign in again.');
      }

      final authOptions = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await apiClient.dio.get('/api/investor/smes', options: authOptions);
      
      if (response.statusCode == 200) {
        return _parseSmeResponse(response.data);
      } else {
        throw Exception('Failed to load SMEs');
      }
    } catch (e) {
      throw Exception('Unable to load SME feed. Please check your connection.');
    }
  }

  List<Map<String, dynamic>> _parseSmeResponse(dynamic data) {
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
  }

  @override
  Future<Map<String, dynamic>> getCachedSmeProfile() async {
    try {
      final cachedStr = await _secureStorage.read(key: 'cached_sme_profile');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        return jsonDecode(cachedStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  @override
  Future<Map<String, dynamic>> getMyInvestorProfile() async {
    try {
      String? token = apiClient.getCachedToken();
      if (token == null || token.isEmpty) {
        token = await _secureStorage.read(key: 'jwt_token');
      }
      
      if (token != null && token.isNotEmpty) {
        final authOptions = Options(headers: {'Authorization': 'Bearer $token'});
        final response = await apiClient.dio.get('/api/investor/me', options: authOptions);
        
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('investor')) {
            return data['investor'] as Map<String, dynamic>;
          }
          return data;
        }
      }
    } catch (e) {}

    try {
      final cachedStr = await _secureStorage.read(key: 'cached_investor_profile');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        return jsonDecode(cachedStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }
}