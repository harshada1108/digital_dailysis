import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:digitaldailysis/utils/colors.dart';

void customSnackBar(String message, {bool isError = true, String title = "Error"}) {
  Get.snackbar(title, message,
      titleText: Text(
        title,
        style: TextStyle(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent);
}
