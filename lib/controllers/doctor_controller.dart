import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/data/repository/doctor_repo.dart';
import 'package:digitaldailysis/models/patient/patient_list_model.dart';
import 'package:digitaldailysis/widgets/custom_snackbar.dart';
import 'package:http/src/response.dart';

import '../routes/route_helper.dart';

class DoctorController extends GetxController implements GetxService {
  final DoctorRepo doctorRepo;

  DoctorController({required this.doctorRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PatientModel> _patients = [];
  List<PatientModel> get patients => _patients;

  Future<void> fetchPatients(String doctorId) async {
    _isLoading = true;
    update();

    dynamic response = await doctorRepo.getPatientsList(doctorId);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        _patients = (decoded['patients'] as List)
            .map((e) => PatientModel.fromJson(e))
            .toList();
      } else {
        customSnackBar("No patients found");
      }
    } else {
      customSnackBar("Failed to load patients");
    }

    _isLoading = false;
    update();
  }

  Future<void> registerPatient(
      String name, String email, String password, String doctorId) async {
    _isLoading = true;
    update();

    dynamic response = await doctorRepo.postregisterPatient(name,email,password,doctorId);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final success = decoded['success'];
      if (success) {
        Get.offNamed(RouteHelper.getDoctorHomeScreen(doctorId));
        Get.snackbar(
          "Success",
          "Patient registered successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to register patient",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }


      _isLoading = false;
    update();

  }

}}
