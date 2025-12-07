import 'package:http/http.dart' as http;
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/utils/app_constants.dart';

class LoginRepo {
  final ApiClient apiClient;
  LoginRepo({required this.apiClient});

  Future<http.Response> login(String loginId, String password) async {
    final body = {
      "email": loginId,
      "password": password,
    };
    return await apiClient.postData(AppConstants.LOGIN_URI, body);
  }
}
