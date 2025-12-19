import 'dart:convert';
import 'package:digitaldailysis/controllers/patient_panel_controller.dart';
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

    http.Response response;
    try {
      response = await loginRepo.login(loginId, password);
    } catch (e) {
      _isLoading = false;
      update();
      customSnackBar("Network error: $e");
      return;
    }

    _isLoading = false;
    update();

    print("Login Status: ${response.statusCode}");
    print("Login Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'] ?? {};
      final role = user['role'] ?? data['role'] ?? '';
      final token = data['token'] ?? '';

      // validate token
      if (token == null || token.toString().isEmpty) {
        customSnackBar("No token found in response");
        return;
      }

      // get user id (robust to _id or id)
      final userId = user['id'] ?? user['_id'] ?? '';

      if (userId.toString().isEmpty) {
        customSnackBar("No user id returned by server");
        return;
      }

      // Save to shared prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.TOKEN, token);
      await prefs.setString("userRole", role);
      await prefs.setString("userId", userId.toString());

      // Update ApiClient header so subsequent requests include token
      try {
        loginRepo.apiClient.updateHeader(token);
      } catch (e) {
        print('Warning: failed to update api client header: $e');
      }

      // Navigate according to role, pass patientId when user is patient
      if (role == 'doctor') {
        Get.offNamed(RouteHelper.getDoctorHomeScreen(userId.toString()));
      } else if (role == 'patient') {
        final patientId = user["id"];

        Get.put(
          PatientPanelController(
            apiClient: loginRepo.apiClient,
            patientId: patientId,
          ),
          tag: patientId,
        );

        Get.toNamed(RouteHelper.getPatientHomeScreen(patientId), arguments: patientId);
      } else {
        customSnackBar("Invalid role received");
        print("Login returned unexpected role: $role");
      }
    } else if (response.statusCode == 401) {
      customSnackBar("Invalid credentials");
    } else {
      // attempt to parse message if any
      try {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? body['error'] ?? '';
        customSnackBar(msg.isNotEmpty ? msg : "Something went wrong. Try again later.");
      } catch (_) {
        customSnackBar("Something went wrong. Try again later.");
      }
    }
  }
}
