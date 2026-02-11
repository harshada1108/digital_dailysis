import 'dart:convert';
import 'package:get/get.dart';
import '../../data/api/api_client.dart';
import '../../utils/app_constants.dart';

class DisplayPatientController extends GetxController {
  final ApiClient apiClient;
  DisplayPatientController({required this.apiClient});

  var isLoading = true.obs;
  var profile = Rxn<Map<String, dynamic>>();

  Future<void> fetchProfile(String patientId) async {
    try {
      isLoading.value = true;

      final response = await apiClient.postData(
        '${AppConstants.BASE_URL}/api/upload/medical-profile',
        {
          "patientId": patientId,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        profile.value = data['profile'];
      } else {
        profile.value = null;
      }
    } catch (e) {
      profile.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
