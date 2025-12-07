import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repository/login_repo.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_snackbar.dart';

class LoginController extends GetxController implements GetxService {
  final LoginRepo loginRepo;

  LoginController({required this.loginRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(String loginId, String password) async {
    _isLoading = true;
    update();

    http.Response response = await loginRepo.login(loginId, password);


    _isLoading = false;
    update();

    print("Login Status: ${response.statusCode}");
    print("Login Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user']; // map
      final role = user['role'];
      final token = data['token'];


      if (token == null || token.toString().isEmpty) {
        customSnackBar("No token found in response");
        return;
      }


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.TOKEN, token);
      await prefs.setString("userRole", role);
      await prefs.setString("userId", user["id"]);


      loginRepo.apiClient.updateHeader(token);


      if (role == 'doctor') {
        Get.offNamed(RouteHelper.getDoctorHomeScreen(user["id"]));
      } else if (role == 'patient') {
        Get.offNamed(RouteHelper.getPatientHomeScreen());
      } else {
        customSnackBar("Invalid role received");
      }
    } else if (response.statusCode == 401) {
      customSnackBar("Invalid credentials");
    } else {
      customSnackBar("Something went wrong. Try again later.");
    }
  }
}
