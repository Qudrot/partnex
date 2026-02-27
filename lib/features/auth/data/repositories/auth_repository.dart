import 'dart:io';

import 'package:partnex/features/auth/data/models/user_model.dart';
import 'package:partnex/features/auth/data/models/credibility_score.dart';

abstract class AuthRepository {

  //Login function that returns user model
  Future<UserModel> login({
    required String email,
    required String password,
  });

  //Registration function that 
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  });

  //Session management function, it check if user exist on app start
  Future<UserModel?> getCurrentUser();

  //Clears token from secure storage
  Future<void> logout();

  // Submits the SME onboarding data and returns the resulting CredibilityScore
  Future<CredibilityScore> submitSmeProfile(Map<String, dynamic> data);

  // Uploads strictly formatted files (e.g. Statement of Accounts) via multipart-form
  Future<void> uploadStatementOfAccount(File file);

  // Retrieves the dashboard feed of SMEs along with their latest credibility score
  Future<List<Map<String, dynamic>>> getInvestorSmes();
}
