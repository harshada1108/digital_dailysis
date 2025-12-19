import 'package:digitaldailysis/pages/patient/day_voluntary_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_panel_controller.dart';

class MaterialSessionDetailsPage extends StatelessWidget {
  final String sessionId;
  final String patientId;

  const MaterialSessionDetailsPage({
    super.key,
    required this.sessionId,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>(tag: patientId);

    final session = controller.summary.value!.materialSessions.firstWhere(
            (s) => s.materialSessionId == sessionId);

    return Scaffold(
      appBar: AppBar(title: const Text("Material Session Details")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Materials",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text("Machine: ${session.materials.dialysisMachine}")),
                  if (session.materials.dialyzer) Chip(label: Text("Dialyzer")),
                  if (session.materials.bloodTubingSets) Chip(label: Text("Tubing")),
                  if (session.materials.dialysisNeedles) Chip(label: Text("Needles")),
                ],
              ),

              SizedBox(height: 20),

              Text("Days", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              ...session.days.map((d) => ListTile(
                title: Text("Day ${d.dayNumber}"),
                subtitle: Text("Status: ${d.status}"),
                onTap: () {
                  if (session.status == "acknowledged" && d.status == "pending") {
                    Get.to(() => DayVoluntaryScreen(
                      materialSessionId: session.materialSessionId,
                      dayNumber: d.dayNumber,
                    ), arguments: patientId);
                  }
                },
              )),

              if (session.status != "acknowledged")
                ElevatedButton(
                  onPressed: () async {
                    final ok = await controller.acknowledgeSession(sessionId);
                    if (ok) {
                      Get.back();
                      Get.snackbar("Success", "Materials Acknowledged");
                    }
                  },
                  child: Text("Acknowledge Materials"),
                ),
            ],
          ),
        );
      }),
    );
  }
}

