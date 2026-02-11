import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/models/patient/patient_profile_model.dart';

class PatientProfileController extends GetxController implements GetxService {
  final ApiClient apiClient;
  final String patientId;

  PatientProfileController({
    required this.apiClient,
    required this.patientId,
  });

  RxBool isLoading = false.obs;
  RxString errorMsg = "".obs;

  Rxn<PatientProfileResponse> profileResponse = Rxn<PatientProfileResponse>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      errorMsg("");

      final uri = '${apiClient.appBaseUrl}/api/upload/medical-profile';

      final http.Response res = await apiClient.postData(
        uri,
        {"patientId": patientId},
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        print("PATIENT PROFILE:");
        print(body);

        profileResponse.value = PatientProfileResponse.fromJson(body);
      } else {
        errorMsg('Failed to fetch profile: ${res.statusCode}');
        print('fetchProfile failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      errorMsg(e.toString());
      print('fetchProfile error: $e');
    } finally {
      isLoading(false);
    }
  }
}
