import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/patient_panel_controller.dart';
import '../../routes/route_helper.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientId;

  const PatientHomeScreen({super.key, required this.patientId});

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMMM yyyy • hh:mm a').format(dt);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.find<PatientPanelController>(tag: patientId);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
        title: const Text('My Dialysis Care'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.summary.value == null) {
          return const Center(child: Text("No data available"));
        }

        final data = controller.summary.value!;
        final patient = data.patient;

        return SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👋 GREETING CARD
              Container(
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1E88E5), Color(0xff1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: size.width * 0.09,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: size.width * 0.1,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${patient.name} 👋',
                            style: TextStyle(
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.004),
                          Text(
                            patient.email,
                            style: TextStyle(
                              fontSize: size.width * 0.038,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.035),

              /// 🧾 MATERIAL SESSIONS HEADER
              Text(
                'My Dialysis Kits',
                style: TextStyle(
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: size.height * 0.015),

              /// 📦 SESSION LIST
              ...data.materialSessions.map((session) {
                final createdAt = session.createdAt;
                final statusColor = _statusColor(session.status);

                return Container(
                  margin: EdgeInsets.only(bottom: size.height * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.getPatientMaterialSessionDetails(
                          session.materialSessionId,
                          controller.patientId,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.045),
                      child: Row(
                        children: [
                          /// STATUS ICON
                          CircleAvatar(
                            radius: size.width * 0.055,
                            backgroundColor:
                            statusColor.withOpacity(0.15),
                            child: Icon(
                              Icons.medical_services,
                              color: statusColor,
                            ),
                          ),

                          SizedBox(width: size.width * 0.04),

                          /// TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dialysis Kit',
                                  style: TextStyle(
                                    fontSize:
                                    size.width * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (createdAt != null)
                                  Text(
                                    _formatDate(
                                        createdAt.toLocal()),
                                    style: TextStyle(
                                      fontSize:
                                      size.width * 0.036,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          /// STATUS CHIP
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.006,
                            ),
                            decoration: BoxDecoration(
                              color:
                              statusColor.withOpacity(0.15),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              session.status.capitalizeFirst!,
                              style: TextStyle(
                                fontSize:
                                size.width * 0.034,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          SizedBox(width: size.width * 0.02),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
