// lib/pages/doctor/patient_info_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/patient_info_controller.dart';

import '../../models/patient/patient_info_model.dart';

class PatientInfoScreen extends StatelessWidget {
  final String patientId;
  // optional doctorId if needed for navigation


  PatientInfoScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create controller for this screen
    final controller = Get.put(PatientInfoController(patientId: patientId));

    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    // sizes
    final titleSize = w * 0.055;
    final subtitleSize = w * 0.04;
    final smallSize = w * 0.034;
    final padding = EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02);
    final cardRadius = w * 0.03;
    final avatarRadius = w * 0.09;

    Widget sessionCard(MaterialSession ms) {
      final bucket = controller.sessionBucket(ms);
      final created = ms.createdAt != null ? ms.createdAt!.toLocal().toString().split('.').first : '';
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        margin: EdgeInsets.only(bottom: h * 0.012),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
          title: Text('Session ${ms.materialSessionId}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: subtitleSize)),
          subtitle: Text('$created • ${ms.status}', style: TextStyle(fontSize: smallSize)),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Materials', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600)),
                  SizedBox(height: h * 0.008),
                  Wrap(
                    spacing: w * 0.02,
                    runSpacing: h * 0.008,
                    children: [
                      _chipFor('Machine: ${ms.materials.dialysisMachine}', w, smallSize),
                      if (ms.materials.dialyzer) _chipFor('Dialyzer', w, smallSize),
                      if (ms.materials.bloodTubingSets) _chipFor('Blood tubing', w, smallSize),
                      if (ms.materials.dialysisNeedles) _chipFor('Needles', w, smallSize),
                      if (ms.materials.dialysateConcentrates) _chipFor('Concentrates', w, smallSize),
                      if (ms.materials.heparin) _chipFor('Heparin', w, smallSize),
                      if (ms.materials.salineSolution) _chipFor('Saline', w, smallSize),
                    ],
                  ),
                  SizedBox(height: h * 0.01),
                  Text('Planned Sessions: ${ms.plannedSessions}', style: TextStyle(fontSize: smallSize)),
                  SizedBox(height: h * 0.008),
                  if (ms.materialImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Images', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600)),
                        SizedBox(height: h * 0.008),
                        SizedBox(
                          height: h * 0.14,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: ms.materialImages.length,
                            separatorBuilder: (_, __) => SizedBox(width: w * 0.02),
                            itemBuilder: (ctx, idx) {
                              final img = ms.materialImages[idx];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                child: Image.network(img.imageUrl, width: w * 0.36, height: h * 0.13, fit: BoxFit.cover),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: h * 0.01),
                  Text('Days', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600)),
                  SizedBox(height: h * 0.008),
                  Column(
                    children: ms.days.map((d) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${d.dayNumber}'), radius: avatarRadius * 0.4),
                        title: Text('Day ${d.dayNumber}', style: TextStyle(fontSize: smallSize, fontWeight: FontWeight.w600)),
                        subtitle: Text('Status: ${d.status}', style: TextStyle(fontSize: smallSize * 0.9)),
                        trailing: d.images.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.image, size: w * 0.06),
                          onPressed: () {
                            // show images in dialog
                            Get.dialog(AlertDialog(
                              content: SizedBox(
                                width: w * 0.8,
                                height: h * 0.6,
                                child: PageView(
                                  children: d.images
                                      .map((im) => Image.network(im.imageUrl, fit: BoxFit.contain))
                                      .toList(),
                                ),
                              ),
                            ));
                          },
                        )
                            : null,
                      );
                    }).toList(),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Patient Info', style: TextStyle(fontSize: titleSize))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: SizedBox(width: w * 0.12, height: w * 0.12, child: CircularProgressIndicator()));
        }

        if (controller.responseModel.value == null) {
          if (controller.errorMsg.value.isNotEmpty) {
            return Center(child: Text(controller.errorMsg.value, style: TextStyle(fontSize: subtitleSize)));
          }
          return Center(child: Text('No data', style: TextStyle(fontSize: subtitleSize)));
        }

        final resp = controller.responseModel.value!;
        final patient = resp.patient;

        final completed = controller.getCompletedSessions();
        final active = controller.getActiveSessions();
        final pending = controller.getPendingSessions();

        return SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic detail card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(w * 0.04),
                  child: Row(
                    children: [
                      CircleAvatar(radius: avatarRadius, child: Icon(Icons.person, size: avatarRadius)),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold)),
                            SizedBox(height: h * 0.008),
                            Text(patient.email, style: TextStyle(fontSize: subtitleSize)),
                            SizedBox(height: h * 0.01),
                            Text('Patient ID: ${patient.id}', style: TextStyle(fontSize: smallSize, color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: h * 0.02),

              // Past sessions header
              Text('Past Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleSize)),
              SizedBox(height: h * 0.008),

              // Active
              if (active.isNotEmpty) ...[
                Text('Active', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600)),
                SizedBox(height: h * 0.01),
                ...active.map(sessionCard).toList(),
              ],

              // Completed
              if (completed.isNotEmpty) ...[
                SizedBox(height: h * 0.01),
                Text('Completed', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600)),
                SizedBox(height: h * 0.01),
                ...completed.map(sessionCard).toList(),
              ],

              // Pending
              if (pending.isNotEmpty) ...[
                SizedBox(height: h * 0.01),
                Text('Pending', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w600)),
                SizedBox(height: h * 0.01),
                ...pending.map(sessionCard).toList(),
              ],

              SizedBox(height: h * 0.02),

              // New materials section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Materials', style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w700)),
                      SizedBox(height: h * 0.01),
                      Text(
                        'Create a new material session to provide supplies / start active dialysis for this patient.',
                        style: TextStyle(fontSize: smallSize),
                      ),
                      SizedBox(height: h * 0.02),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // navigate to your existing create page
                                // e.g. Get.toNamed(RouteHelper.getCreateActiveDialysisScreen(patientId, doctorId ?? ''));
                                Get.snackbar('TODO', 'Navigate to Create Active Dialysis page');
                              },
                              icon: Icon(Icons.add, size: w * 0.05),
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: h * 0.012),
                                child: Text('Create Active Dialysis', style: TextStyle(fontSize: smallSize)),
                              ),
                            ),
                          ),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // optionally allow manual upload of material data / images
                                Get.snackbar('TODO', 'Open material upload flow');
                              },
                              icon: Icon(Icons.upload_file, size: w * 0.05),
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: h * 0.012),
                                child: Text('Upload Material Images', style: TextStyle(fontSize: smallSize)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: h * 0.04),
            ],
          ),
        );
      }),
    );
  }

  Widget _chipFor(String text, double w, double fontSize) {
    return Chip(
      label: Text(text, style: TextStyle(fontSize: fontSize)),
    );
  }
}
