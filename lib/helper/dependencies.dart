

import 'package:digitaldailysis/controllers/Patient_info_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/doctor_controller.dart';
import '../controllers/login_controller.dart';
import '../data/api/api_client.dart';
import '../data/repository/doctor_repo.dart';
import '../data/repository/login_repo.dart';
import '../utils/app_constants.dart';

Future<void> init() async {

  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences); // ✅ store it for reuse
  Get.put(ApiClient(appBaseUrl: AppConstants.BASE_URL, sharedPreferences: sharedPreferences));
  Get.put(LoginRepo(apiClient: Get.find()));
  Get.put(LoginController(loginRepo: Get.find()));
  // Repositories
  Get.put(DoctorRepo(apiClient: Get.find()));
  Get.put(PatientInfoController(patientId: ''));

  // Controllers
  Get.put(DoctorController(doctorRepo: Get.find()));
}
