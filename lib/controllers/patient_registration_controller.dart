// lib/controllers/patient_registration_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/utils/app_constants.dart';

class PatientRegistrationController extends GetxController {
  final ApiClient apiClient;


  PatientRegistrationController( {required this.apiClient});

  // Loading states
  var isLoading = false.obs;
  var currentStep = 0.obs;


  // Step 1: Basic Registration
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Step 2: Medical Profile
  final ageController = TextEditingController();
  final crNumberController = TextEditingController();
  final contactNumberController = TextEditingController();
  final addressController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final emergencyRelationController = TextEditingController();

  var selectedGender = 'Male'.obs;
  var selectedEducation = 'Graduate'.obs;
  var selectedIncome = 'Lower middle'.obs;
  var selectedDialysisType = 'PD'.obs;

  final primaryDiagnosisController = TextEditingController();
  final nativeKidneyDiseaseController = TextEditingController();
  final allergiesController = TextEditingController();

  // Step 3: Baseline Assessment
  final catheterInsertionDate = Rx<DateTime?>(null);
  final pdStartDate = Rx<DateTime?>(null);
  final trainingStartDate = Rx<DateTime?>(null);
  final trainingCompletionDate = Rx<DateTime?>(null);

  var selectedCatheterTechnique = 'Surgical'.obs;
  var hasComplications = false.obs;
  final complicationsDetailsController = TextEditingController();

  // Clinical Exam
  final pulseController = TextEditingController();
  final bpSystolicController = TextEditingController();
  final bpDiastolicController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  var hasPallor = false.obs;
  var hasIcterus = false.obs;
  var hasCyanosis = false.obs;
  var hasClubbing = false.obs;
  var hasEdema = false.obs;

  // PD Prescription (simplified for one exchange)
  final dwellTimingController = TextEditingController();
  final solutionStrengthController = TextEditingController();
  final fillVolumeController = TextEditingController();
  final dwellDurationController = TextEditingController();
  final numberOfExchangesController = TextEditingController();
  var icodextrinUsed = false.obs;

  // Labs
  final hemoglobinController = TextEditingController();
  final hemoglobinDate = Rx<DateTime?>(null);
  final ureaController = TextEditingController();
  final ureaDate = Rx<DateTime?>(null);
  final creatinineController = TextEditingController();
  final creatinineDate = Rx<DateTime?>(null);

  // Plan
  final advisedPrescriptionController = TextEditingController();
  final medicationsController = TextEditingController();
  final followUpController = TextEditingController();

  // Store registered patient ID
  var registeredPatientId = ''.obs;

  @override
  void onClose() {
    // Dispose all controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    ageController.dispose();
    crNumberController.dispose();
    contactNumberController.dispose();
    addressController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    emergencyRelationController.dispose();
    primaryDiagnosisController.dispose();
    nativeKidneyDiseaseController.dispose();
    allergiesController.dispose();
    complicationsDetailsController.dispose();
    pulseController.dispose();
    bpSystolicController.dispose();
    bpDiastolicController.dispose();
    weightController.dispose();
    heightController.dispose();
    dwellTimingController.dispose();
    solutionStrengthController.dispose();
    fillVolumeController.dispose();
    dwellDurationController.dispose();
    numberOfExchangesController.dispose();
    hemoglobinController.dispose();
    ureaController.dispose();
    creatinineController.dispose();
    advisedPrescriptionController.dispose();
    medicationsController.dispose();
    followUpController.dispose();
    super.onClose();
  }

  // Step 1: Register Patient
  Future<bool> registerPatient(doctorId) async {
    try {
      isLoading.value = true;

      final body = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": passwordController.text.trim(),
        "role":"patient",
        "doctorId":doctorId,
      };

      final response = await apiClient.postData(
        '${AppConstants.BASE_URL}/api/auth/register',
        body,
      );

      print("Register Patient Response: ${response.statusCode}");
      print("Register Patient Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check for success flag
        if (responseData['success'] == true) {
          // Try multiple possible paths for patient ID - UPDATED TO INCLUDE userId
          registeredPatientId.value =
              responseData['userId'] ??           // ✅ This is what your API returns
                  responseData['patientId'] ??
                  responseData['patient']?['_id'] ??
                  responseData['data']?['_id'] ??
                  responseData['_id'] ??
                  '';

          if (registeredPatientId.value.isEmpty) {
            Get.snackbar(
              'Error',
              'Patient registered but ID not found in response',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            print("Full response: ${response.body}");
            return false;
          }

          print("✅ Patient registered successfully with ID: ${registeredPatientId.value}");

          Get.snackbar(
            'Success',
            'Patient registered successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );

          currentStep.value = 1;
          return true;
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Registration failed',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          errorData['message'] ?? 'Failed to register patient',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to register patient: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      print("Exception in registerPatient: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Step 2: Create Medical Profile
  Future<bool> createMedicalProfile() async {
    try {
      isLoading.value = true;

      // Validate we have patient ID
      if (registeredPatientId.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Patient ID not found. Please register the patient first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        currentStep.value = 0; // Go back to step 1
        return false;
      }

      List<String> allergiesList = allergiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final body = {
        "patientId": registeredPatientId.value,
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "gender": selectedGender.value,
        "crNumber": crNumberController.text.trim(),
        "contactNumber": contactNumberController.text.trim(),
        "address": addressController.text.trim(),
        "educationLevel": selectedEducation.value,
        "incomeLevel": selectedIncome.value,
        "primaryDiagnosis": primaryDiagnosisController.text.trim(),
        "nativeKidneyDisease": nativeKidneyDiseaseController.text.trim(),
        "dialysisType": selectedDialysisType.value,
        "allergies": allergiesList,
        "emergencyContact": {
          "name": emergencyNameController.text.trim(),
          "phone": emergencyPhoneController.text.trim(),
          "relation": emergencyRelationController.text.trim(),
        }
      };

      print("Creating medical profile for patient: ${registeredPatientId.value}");
      print("Medical profile body: ${jsonEncode(body)}");

      final response = await apiClient.postData(
        '${AppConstants.BASE_URL}/api/upload/medical-profile',
        body,
      );

      print("Medical Profile Response: ${response.statusCode}");
      print("Medical Profile Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Medical profile created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        currentStep.value = 2;
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            errorData['message'] ?? 'Failed to create medical profile',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to create medical profile (Status: ${response.statusCode})',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create medical profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      print("Exception in createMedicalProfile: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Step 3: Create Baseline Assessment
  Future<bool> createBaselineAssessment() async {
    try {
      isLoading.value = true;

      // Validate we have patient ID
      if (registeredPatientId.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Patient ID not found. Please complete registration from the beginning.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        currentStep.value = 0; // Go back to step 1
        return false;
      }

      final body = {
        "patientId": registeredPatientId.value,
        "primaryDiagnosis": primaryDiagnosisController.text.trim(),
        "nativeKidneyDisease": nativeKidneyDiseaseController.text.trim(),
        "dialysisType": selectedDialysisType.value,
        "pdCatheterInsertionDate": catheterInsertionDate.value?.toIso8601String().split('T')[0],
        "catheterTechnique": selectedCatheterTechnique.value,
        "pdStartDate": pdStartDate.value?.toIso8601String().split('T')[0],
        "trainingStartDate": trainingStartDate.value?.toIso8601String().split('T')[0],
        "trainingCompletionDate": trainingCompletionDate.value?.toIso8601String().split('T')[0],
        "periImplantComplications": {
          "present": hasComplications.value,
          "details": complicationsDetailsController.text.trim(),
        },
        "clinicalExam": {
          "pulse": int.tryParse(pulseController.text.trim()) ?? 0,
          "bpSystolic": int.tryParse(bpSystolicController.text.trim()) ?? 0,
          "bpDiastolic": int.tryParse(bpDiastolicController.text.trim()) ?? 0,
          "weightKg": double.tryParse(weightController.text.trim()) ?? 0.0,
          "heightCm": double.tryParse(heightController.text.trim()) ?? 0.0,
          "pallor": hasPallor.value,
          "icterus": hasIcterus.value,
          "cyanosis": hasCyanosis.value,
          "clubbing": hasClubbing.value,
          "edema": hasEdema.value,
        },
        "pdPrescription": [
          {
            "dwellTiming": dwellTimingController.text.trim(),
            "solutionStrength": solutionStrengthController.text.trim(),
            "fillVolume": int.tryParse(fillVolumeController.text.trim()) ?? 0,
            "dwellDurationHours": int.tryParse(dwellDurationController.text.trim()) ?? 0,
            "numberOfExchanges": int.tryParse(numberOfExchangesController.text.trim()) ?? 0,
            "icodextrinUsed": icodextrinUsed.value,
          }
        ],
        "labs": {
          "hemoglobin": {
            "value": double.tryParse(hemoglobinController.text.trim()) ?? 0.0,
            "date": hemoglobinDate.value?.toIso8601String().split('T')[0],
          },
          "urea": {
            "value": double.tryParse(ureaController.text.trim()) ?? 0.0,
            "date": ureaDate.value?.toIso8601String().split('T')[0],
          },
          "creatinine": {
            "value": double.tryParse(creatinineController.text.trim()) ?? 0.0,
            "date": creatinineDate.value?.toIso8601String().split('T')[0],
          },
        },
        "planAndAdvice": {
          "advisedPrescription": advisedPrescriptionController.text.trim(),
          "medications": medicationsController.text.trim(),
          "followUpInstructions": followUpController.text.trim(),
        }
      };

      print("Creating baseline assessment for patient: ${registeredPatientId.value}");

      final response = await apiClient.patchData(
        '${AppConstants.BASE_URL}/api/upload/doctor/baseline-assessment',
        body,
      );

      print("Baseline Assessment Response: ${response.statusCode}");
      print("Baseline Assessment Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Patient registration completed successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        // Clear all form data
        _clearAllForms();

        // Navigate back or to patient list after a short delay
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            errorData['message'] ?? 'Failed to create baseline assessment',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to create baseline assessment (Status: ${response.statusCode})',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create baseline assessment: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      print("Exception in createBaselineAssessment: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _clearAllForms() {
    // Step 1
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();

    // Step 2
    ageController.clear();
    crNumberController.clear();
    contactNumberController.clear();
    addressController.clear();
    emergencyNameController.clear();
    emergencyPhoneController.clear();
    emergencyRelationController.clear();
    primaryDiagnosisController.clear();
    nativeKidneyDiseaseController.clear();
    allergiesController.clear();

    // Step 3
    complicationsDetailsController.clear();
    pulseController.clear();
    bpSystolicController.clear();
    bpDiastolicController.clear();
    weightController.clear();
    heightController.clear();
    dwellTimingController.clear();
    solutionStrengthController.clear();
    fillVolumeController.clear();
    dwellDurationController.clear();
    numberOfExchangesController.clear();
    hemoglobinController.clear();
    ureaController.clear();
    creatinineController.clear();
    advisedPrescriptionController.clear();
    medicationsController.clear();
    followUpController.clear();

    // Reset observables
    currentStep.value = 0;
    registeredPatientId.value = '';
    catheterInsertionDate.value = null;
    pdStartDate.value = null;
    trainingStartDate.value = null;
    trainingCompletionDate.value = null;
    hemoglobinDate.value = null;
    ureaDate.value = null;
    creatinineDate.value = null;
    hasComplications.value = false;
    hasPallor.value = false;
    hasIcterus.value = false;
    hasCyanosis.value = false;
    hasClubbing.value = false;
    hasEdema.value = false;
    icodextrinUsed.value = false;
    selectedGender.value = 'Male';
    selectedEducation.value = 'Graduate';
    selectedIncome.value = 'Lower middle';
    selectedDialysisType.value = 'PD';
    selectedCatheterTechnique.value = 'Surgical';
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
}