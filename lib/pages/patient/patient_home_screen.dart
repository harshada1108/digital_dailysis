import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_panel_controller.dart';
import '../../routes/route_helper.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientId;

  const PatientHomeScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patientId = Get.arguments;

    final controller = Get.find<PatientPanelController>(tag: patientId);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("Patient Panel")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.summary.value == null) {
          return const Center(child: Text("No data"));
        }

        final data = controller.summary.value!;
        final patient = data.patient;

        return SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info card
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.1,
                        child: const Icon(Icons.person),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.name,
                              style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold)),
                          Text(patient.email,
                              style: TextStyle(fontSize: size.width * 0.04)),
                          Text("ID: ${patient.id}",
                              style: TextStyle(fontSize: size.width * 0.035))
                        ],
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              Text("Material Sessions",
                  style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: size.height * 0.01),

              ...data.materialSessions.map((session) {
                final date = session.createdAt?.toLocal().toString().split(".")[0];

                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.blue.shade50,
                  title: Text("Material Session"),
                  subtitle: Text("$date • ${session.status}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {


                    Get.toNamed(
                      RouteHelper.getPatientMaterialSessionDetails(
                        session.materialSessionId,
                        controller.patientId,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
