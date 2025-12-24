import 'package:digitaldailysis/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/widgets/custom_snackbar.dart';

class DoctorMaterialController extends GetxController {
  final ApiClient apiClient;
  DoctorMaterialController({required this.apiClient});

  RxBool isVerifying = false.obs;

  Future<bool> verifyDialysisSession({
    required String sessionId,
    required String notes,
  }) async {
    try {
      isVerifying(true);

      final res = await apiClient.patchData(
        AppConstants.BASE_URL +
        '/api/upload/verify-dialysis-session',
        {
          "sessionId": sessionId,
          "verificationNotes": notes,
        },

      );

      if (res.statusCode == 200) {



        return true;
      } else {

        return false;
      }
    } catch (e) {

    } finally {
      isVerifying(false);
    }
    return false;
  }

}
