import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://partnex-backend.onrender.com'));
  
  try {
    final userSuffix = DateTime.now().millisecondsSinceEpoch.toString();
    final registerRes = await dio.post('/api/auth/register', data: {
      "email": "investor_$userSuffix@test.com",
      "password": "Password123",
      "role": "investor"
    });
    
    final token = registerRes.data['token'];

    final smesRes = await dio.get('/api/investor/smes',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    print(encoder.convert(smesRes.data));
    
  } on DioException catch (e) {
    print("Dio Error: ${e.response?.statusCode} - ${e.response?.data}");
  } catch (e) {
    print("Other Error: $e");
  }
}
