import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/display_patient_controller.dart';
import '../../utils/colors.dart';

class DisplayPatientPage extends StatelessWidget {
  final String patientId;
  const DisplayPatientPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(DisplayPatientController(apiClient: Get.find()));

    controller.fetchProfile(patientId);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("My Medical Profile"),
        backgroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.profile.value == null) {
          return const Center(child: Text("Profile not created yet"));
        }

        final p = controller.profile.value!;

        return SingleChildScrollView(
          child: Column(
            children: [
              _headerCard(p),
              _infoCard("Personal Information", [
                _tile(Icons.person, "Age", p['age'].toString()),
                _tile(Icons.wc, "Gender", p['gender']),
                _tile(Icons.phone, "Contact", p['contactNumber']),
                _tile(Icons.home, "Address", p['address']),
                _tile(Icons.confirmation_number, "CR Number", p['crNumber']),
              ]),
              _infoCard("Medical Details", [
                _tile(Icons.healing, "Diagnosis", p['primaryDiagnosis']),
                _tile(Icons.local_hospital, "Kidney Disease", p['nativeKidneyDisease']),
                _tile(Icons.opacity, "Dialysis Type", p['dialysisType']),
                _tile(Icons.school, "Education", p['educationLevel']),
                _tile(Icons.monetization_on, "Income Level", p['incomeLevel']),
              ]),
              _infoCard("Emergency Contact", [
                _tile(Icons.person, "Name", p['emergencyContact']['name']),
                _tile(Icons.phone, "Phone", p['emergencyContact']['phone']),
                _tile(Icons.group, "Relation", p['emergencyContact']['relation']),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );

  }

  Widget _headerCard(Map p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.darkPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Patient Profile",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            p['crNumber'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p['primaryDiagnosis'],
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          ...children
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
