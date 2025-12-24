// lib/controllers/patient_info_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:digitaldailysis/models/patient/patient_info_model.dart';
import 'package:digitaldailysis/data/api/api_client.dart';

class PatientInfoController extends GetxController {
  // Single material session details (doctor view)
  var isMaterialSessionLoading = false.obs;
  var materialSessionError = ''.obs;
  var materialSessionDetails = Rxn<MaterialSession>();
  final String patientId;
  PatientInfoController({required this.patientId});

  var isLoading = false.obs;
  var errorMsg = ''.obs;
  var responseModel = Rxn<PatientInfoResponse>();

  late ApiClient apiClient;

  @override
  void onInit() {
    super.onInit();
    apiClient = Get.find<ApiClient>();
    fetchPatientInfo();
  }

  /// Fetch patient material summary, which returns patient + materialSessions + days
  Future<void> fetchPatientInfo() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      // IMPORTANT: this is the material-summary endpoint you showed in Postman
      final uri = '${apiClient.appBaseUrl}/api/upload/patient/material-summary';

      // apiClient.postData expects a full URI string and a JSON body (it handles auth header)
      final http.Response res = await apiClient.postData(uri, {'patientId': patientId});

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        // ensure correct structure before parsing
        if (body['success'] == true && body['patient'] != null) {
          responseModel.value = PatientInfoResponse.fromJson(body);
        } else {
          errorMsg.value = 'No data in response';
          print('fetchPatientInfo: unexpected response body: $body');
        }
      } else {
        errorMsg.value = 'Server error: ${res.statusCode}';
        print('fetchPatientInfo failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      errorMsg.value = 'Failed to fetch patient info';
      print('fetchPatientInfo err: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Public helper to refresh page (pull-to-refresh etc)
  Future<void> refresh() async {
    await fetchPatientInfo();
  }

  /// Bucket logic — unchanged
  String sessionBucket(MaterialSession ms) {
    final days = ms.days;
    if (days.isEmpty) return 'pending';
    final completed = days.where((d) => d.status.toLowerCase() == 'completed').length;
    final pending = days.where((d) => d.status.toLowerCase() == 'pending').length;
    if (completed > 0 && pending == 0) return 'completed';
    if (completed > 0 && pending > 0) return 'active';
    return 'pending';
  }

  List<MaterialSession> getCompletedSessions() {
    final m = responseModel.value?.materialSessions ?? [];
    return m.where((s) => sessionBucket(s) == 'completed').toList();
  }

  List<MaterialSession> getActiveSessions() {
    final m = responseModel.value?.materialSessions ?? [];
    return m.where((s) => sessionBucket(s) == 'active').toList();
  }

  List<MaterialSession> getPendingSessions() {
    final m = responseModel.value?.materialSessions ?? [];
    return m.where((s) => sessionBucket(s) == 'pending').toList();
  }

  /// Fetch single material session details (Doctor view)
  Future<void> fetchMaterialSessionDetailsByDoc({
    required String patientId,
    required String materialSessionId,
  }) async {
    try {
      isMaterialSessionLoading.value = true;
      materialSessionError.value = '';

      final uri =
          '${apiClient.appBaseUrl}/api/upload/material/session-details';

      final http.Response res = await apiClient.postData(
        uri,
        {
          'patientId': patientId,
          'materialSessionId': materialSessionId,
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);

        if (body['success'] == true && body['materialSession'] != null) {
          materialSessionDetails.value =
              MaterialSession.fromJson(body['materialSession']);
        } else {
          materialSessionError.value = 'Invalid response from server';
          print('session-details unexpected body: $body');
        }
      } else {
        materialSessionError.value =
        'Server error: ${res.statusCode}';
        print(
            'session-details failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      materialSessionError.value =
      'Failed to load session details';
      print('fetchMaterialSessionDetailsByDoc error: $e');
    } finally {
      isMaterialSessionLoading.value = false;
    }
  }


}
