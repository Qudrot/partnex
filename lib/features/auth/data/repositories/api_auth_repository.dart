import 'package:dio/dio.dart';
import 'package:partnest/core/network/api_client.dart';
import 'package:partnest/features/auth/data/models/user_model.dart';
import 'package:partnest/features/auth/data/models/credibility_score.dart';
import 'package:partnest/features/auth/data/repositories/auth_repository.dart';

/// The official repository that connects your Flutter UI to your
/// local Express.js & MySQL backend.
class ApiAuthRepository implements AuthRepository {
  final ApiClient apiClient;

  ApiAuthRepository({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      // Calls POST /auth/login on your local backend
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Your backend returns: { user: { id, email, role }, token: "..." }
      final userData = response.data['user'];
      
      // We map the string role from the backend into our Flutter Enum
      UserRole parsedRole = UserRole.sme; // Default fallback
      if (userData['role'] == 'sme') parsedRole = UserRole.sme;
      if (userData['role'] == 'investor') parsedRole = UserRole.investor;

      // TODO(Auth): Save response.data['token'] to SecureStorage here!

      return UserModel(
        id: userData['id'].toString(), // Backend returns int, UserModel expects String
        email: userData['email'],
        name: 'SME user', // Your backend 'users' table doesn't have 'name', you may want to add it!
        role: parsedRole,
        profilePicture: '', 
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to login');
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
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'role': 'sme', 
        },
      );

      // Same payload extraction as login
      final userData = response.data['user'];

      return UserModel(
        id: userData['id'].toString(),
        email: userData['email'],
        name: name, 
        role: UserRole.sme,
        profilePicture: '',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to register');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<CredibilityScore> submitSmeProfile(Map<String, dynamic> data) async {
    try {
      // MVP DIRECT AI INTEGRATION: Bypass db save and hit AI analysis directly
      // Map the SmeProfileCubit data to the financial numbers the `/api/score/analyze` endpoint expects.

      final employees = int.tryParse(data['numberOfEmployees'].toString()) ?? 1;
      final monthlyRev = double.tryParse(data['monthlyAvgRevenue'].toString()) ?? 0;
      final monthlyExp = double.tryParse(data['monthlyAvgExpenses'].toString()) ?? 0;
      final liabilities = double.tryParse(data['existingLiabilities'].toString()) ?? 0;

      final annualRevenue = monthlyRev * 12;
      final annualExpenses = monthlyExp * 12;
      
      final expenseRatio = annualRevenue > 0 ? annualExpenses / annualRevenue : 0.5;
      final profitMargin = annualRevenue > 0 ? (annualRevenue - annualExpenses) / annualRevenue : 0.1;
      
      // Rough MVP estimates
      final annualLoanRepayments = liabilities * 0.2; 
      final debtServiceRatio = annualRevenue > 0 ? annualLoanRepayments / annualRevenue : 0.1;
      final transactionActivity = employees * 10;

      final smeFinancialData = {
        "transaction_activity": transactionActivity,
        "annual_revenue": annualRevenue,
        "annual_expenses": annualExpenses,
        "expense_ratio": expenseRatio,
        "profit_margin": profitMargin,
        "annual_loan_repayments": annualLoanRepayments,
        "debt_service_ratio": debtServiceRatio
      };

      print('🚀 SENDING DIRECT AI PAYLOAD: \$smeFinancialData');

      final response = await apiClient.dio.post(
        '/api/score/analyze',
        data: smeFinancialData,
      );
      
      // The backend returns { results: { credibility_score, risk_level, explanation: { strengths, risks } } }
      final scoreData = response.data['results'];

      // Extract risk level string and map to enum
      RiskLevel rLevel = RiskLevel.low;
      if (scoreData['risk_level'] == 'MEDIUM' || scoreData['risk_level'] == 'Medium Risk') rLevel = RiskLevel.medium;
      if (scoreData['risk_level'] == 'HIGH' || scoreData['risk_level'] == 'High Risk') rLevel = RiskLevel.high;

      // Safe extraction of explanation data
      final explanation = scoreData['explanation'] ?? {};
      List<String> strengths = [];
      if (explanation['strengths'] != null) {
        strengths = List<String>.from(explanation['strengths']);
      }
      
      List<String> risks = [];
      if (explanation['risks'] != null) {
        risks = List<String>.from(explanation['risks']);
      }

      return CredibilityScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Dummy ID
        organisationId: 'direct_analysis',
        totalScore: (scoreData['credibility_score'] as num).toDouble(),
        riskLevel: rLevel,
        topContributingFactors: strengths,
        generalExplanation: risks.isNotEmpty ? risks.join('. ') : '',
        calculatedAt: DateTime.now(),
      );

    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to generate direct AI score.');
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
    // TODO: Implement clearing token from local storage
  }
}
