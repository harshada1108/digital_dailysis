import 'package:digitaldailysis/pages/patient/day_dailysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_panel_controller.dart';

class DayVoluntaryScreen extends StatelessWidget {
  final String materialSessionId;
  final int dayNumber;

  const DayVoluntaryScreen({
    super.key,
    required this.materialSessionId,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    final patientId = Get.arguments;
    final controller = Get.find<PatientPanelController>(tag: patientId);

    return Scaffold(
      appBar: AppBar(title: Text("Day $dayNumber")),
      body: Center(
        child: Obx(() {
          return controller.isLoading.value
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () async {
              final sessionId =
              await controller.startDialysisDay(materialSessionId);

              if (sessionId != null) {
                Get.to(() => DayDialysisScreen(
                  sessionId: sessionId,
                  dayNumber: dayNumber,
                ), arguments: patientId);
              }
            },
            child: Text("Start Dialysis"),
          );
        }),
      ),
    );
  }
}
