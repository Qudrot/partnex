import 'dart:io';

import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';
import 'package:partnex/features/auth/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  
  @override
  Future<UserModel> login({required String email, required String password}) async {
    // TODO(API): Replace this Future.delayed with your Dio.post request to /auth/login
    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@partnex.com" && password == "password") {
      return UserModel(
        id: "U-123",
        email: email,
        name: "Test User",
        role: UserRole.sme, // Defaulting to SME for test
        profilePicture: "",
      );
    } else {
      throw Exception("Invalid credentials. Try test@partnex.com / password");
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    // TODO(API): Replace with Dio.post to /auth/signup
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(
      id: "U-124",
      email: email,
      name: name,
      role: UserRole.sme,
      profilePicture: "",
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO(API): Check secure storage for token, then verify with backend GET /auth/me
    await Future.delayed(const Duration(seconds: 1));
    return null; // returning null to force login by default
  }

  @override
  Future<void> logout() async {
    // TODO(API): Clear token from secure storage and call backend logout if needed
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<CredibilityScore> submitSmeProfile(Map<String, dynamic> data) async {
    // TODO(API): Replace this with a Dio.post request sending `data` to your score generation endpoint
    // e.g. final response = await dio.post('/api/v1/score', data: data);
    // return CredibilityScore.fromJson(response.data);
    
    await Future.delayed(const Duration(seconds: 3)); // Simulate processing time

    return CredibilityScore(
      id: "SCORE-999",
      organisationId: "ORG-111",
      totalScore: 85.0,
      riskLevel: RiskLevel.low,
      calculatedAt: DateTime.now(),
      topContributingFactors: ["Consistent Revenue Tracking", "Low Liabilities"],
    );
  }

  @override
  Future<void> uploadStatementOfAccount(File file) async {
    // Mock upload delay
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<List<Map<String, dynamic>>> getInvestorSmes() async {
    // Mock investor feed
    await Future.delayed(const Duration(seconds: 2));
    return [
      {
         "sme_id": "ORG-111",
         "business_name": "Test Company",
         "score": 85.0,
         "risk_level": "LOW",
      }
    ];
  }
}
