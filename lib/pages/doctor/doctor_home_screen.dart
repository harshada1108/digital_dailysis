import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/doctor_controller.dart';
import 'package:digitaldailysis/routes/route_helper.dart';

class DoctorHomePage extends StatefulWidget {
  final String doctorId;

  const DoctorHomePage({super.key, required this.doctorId});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  late DoctorController doctorController;

  @override
  void initState() {
    super.initState();
    doctorController = Get.find<DoctorController>();

    // ✅ Safe to call here
    Future.delayed(Duration.zero, () {
      doctorController.fetchPatients(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Patients",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(
            RouteHelper.getRegisterPatientScreen(widget.doctorId),
          );

          if (result == true) {
            // ✅ Refresh after successful registration
            doctorController.fetchPatients(widget.doctorId);
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: GetBuilder<DoctorController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.patients.isEmpty) {
            return const Center(
              child: Text(
                "No patients found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: ListView.builder(
              itemCount: controller.patients.length,
              itemBuilder: (context, index) {
                final patient = controller.patients[index];
                return Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16),
                  ),


                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    title: Text(
                      patient.name,
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      patient.email,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blueAccent,
                      size: size.width * 0.04,
                    ),
                    onTap: () {
                      // navigate by named route (recommended)
                      Get.toNamed(
                        RouteHelper.getPatientInfoScreen(
                            patient.id),
                      );
                    }
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
