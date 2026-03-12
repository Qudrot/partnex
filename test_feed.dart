import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://partnex-backend.onrender.com'));
  
  try {
    final userSuffix = DateTime.now().millisecondsSinceEpoch.toString();
    final registerRes = await dio.post('/api/auth/register', data: {
      "email": "investor_$userSuffix@test.com",
      "password": "Password123!",
      "role": "investor",
      "name": "Test"
    });
    
    final token = registerRes.data['token'];

    final smesRes = await dio.get('/api/investor/smes',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    
    final data = smesRes.data;
    if (data['smes'] != null) {
      for (var sme in data['smes']) {
         print("SME: ${sme['business_name']} - Score: ${sme['score']} (Type: ${sme['score'].runtimeType})");
      }
    } else {
      print("No smes array found. Data keys: ${data.keys}");
    }
    
  } on DioException catch (e) {
    print("Dio Error: ${e.response?.statusCode} - ${e.response?.data}");
  } catch (e) {
    print("Other Error: $e");
  }
}
