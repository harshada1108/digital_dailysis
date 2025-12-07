// lib/controllers/patient_info_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/patient/patient_info_model.dart';
import '../models/patient/patient_info_model.dart';
import '../data/api/api_client.dart';

class PatientInfoController extends GetxController {
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

  Future<void> fetchPatientInfo() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';

      // Post body requires patientId per your Postman screenshot
      final uri = '${apiClient.appBaseUrl}/api/upload/patient/details';
      final http.Response res = await apiClient.postData(uri, {'patientId': patientId});

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        responseModel.value = PatientInfoResponse.fromJson(body);
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

  /// Helper to decide session-level bucket using the day's statuses:
  /// - Completed: all days status == 'completed'
  /// - Active: some completed AND some pending
  /// - Pending: no completed days (all pending or not started)
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
}
