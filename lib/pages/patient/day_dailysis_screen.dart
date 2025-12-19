import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/patient_panel_controller.dart';

class DayDialysisScreen extends StatefulWidget {
  final String sessionId;
  final int dayNumber;

  const DayDialysisScreen({
    super.key,
    required this.sessionId,
    required this.dayNumber,
  });

  @override
  State<DayDialysisScreen> createState() => _DayDialysisScreenState();
}

class _DayDialysisScreenState extends State<DayDialysisScreen> {
  String feelingOk = "yes";
  String fever = "no";

  final comment = TextEditingController();
  final fillVolume = TextEditingController();
  final drainVolume = TextEditingController();
  final fillTime = TextEditingController();
  final drainTime = TextEditingController();
  final bp = TextEditingController();
  final weightPre = TextEditingController();
  final weightPost = TextEditingController();
  final exchanges = TextEditingController();
  final duration = TextEditingController();

  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>();

    return Scaffold(
      appBar: AppBar(title: Text("Dialysis Day ${widget.dayNumber}")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            /// VOLUNTARY
            Text("Feeling OK?"),
            DropdownButton(
              value: feelingOk,
              items: ["yes", "no"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => feelingOk = v!),
            ),

            Text("Fever?"),
            DropdownButton(
              value: fever,
              items: ["yes", "no"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => fever = v!),
            ),

            TextField(controller: comment, decoration: InputDecoration(labelText: "Comment")),

            SizedBox(height: 20),
            Divider(),

            /// TECHNICAL PARAMETERS
            TextField(controller: fillVolume, decoration: InputDecoration(labelText: "Fill Volume")),
            TextField(controller: drainVolume, decoration: InputDecoration(labelText: "Drain Volume")),
            TextField(controller: fillTime, decoration: InputDecoration(labelText: "Fill Time")),
            TextField(controller: drainTime, decoration: InputDecoration(labelText: "Drain Time")),
            TextField(controller: bp, decoration: InputDecoration(labelText: "Blood Pressure")),
            TextField(controller: weightPre, decoration: InputDecoration(labelText: "Weight Pre")),
            TextField(controller: weightPost, decoration: InputDecoration(labelText: "Weight Post")),
            TextField(controller: exchanges, decoration: InputDecoration(labelText: "Number Of Exchanges")),
            TextField(controller: duration, decoration: InputDecoration(labelText: "Duration (mins)")),

            SizedBox(height: 20),

            /// UPLOAD IMAGE
            selectedImage == null
                ? Text("No image selected")
                : Image.file(selectedImage!, height: 150),

            ElevatedButton(
              onPressed: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => selectedImage = File(picked.path));
                }
              },
              child: Text("Select Image"),
            ),

            SizedBox(height: 20),

            /// FINISH BUTTON
            Obx(() {
              return controller.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  /// 1. Upload image (if selected)
                  if (selectedImage != null) {
                    await controller.uploadDialysisImage(
                      widget.sessionId,
                      selectedImage!.path,
                    );
                  }

                  /// 2. Finish dialysis (main API)
                  final success = await controller.finishDialysisDay(
                    widget.sessionId,
                    {
                      "feelingOk": feelingOk,
                      "fever": fever,
                      "comment": comment.text,
                      "fillVolume": fillVolume.text,
                      "drainVolume": drainVolume.text,
                      "fillTime": fillTime.text,
                      "drainTime": drainTime.text,
                      "bloodPressure": bp.text,
                      "weightPre": weightPre.text,
                      "weightPost": weightPost.text,
                      "numberOfExchanges": int.tryParse(exchanges.text) ?? 0,
                      "durationMinutes": int.tryParse(duration.text) ?? 0,
                    },
                  );

                  if (success) {
                    /// 3. Show success snackbar
                    Get.snackbar(
                      "Success",
                      "Dialysis Completed Successfully",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );

                    /// 4. Refresh Material Summary so day updates from pending → completed
                    await controller.fetchPatientMaterialSummary();

                    /// 5. Navigate back to MaterialSessionDetails page
                    Get.back();     // closes DayDialysisScreen

                    /// (Optional double back if you opened voluntary screen before)
                    // Get.back();  // use only if required
                  }
                },

                child: Text("Finish Dialysis"),
              );
            }),
          ],
        ),
      ),
    );
  }
}
