import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digitaldailysis/controllers/create_material_controller.dart';

class CreateActiveMaterialScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;

  const CreateActiveMaterialScreen({
    Key? key,
    required this.doctorId,
    required this.patientId,
  }) : super(key: key);

  @override
  State<CreateActiveMaterialScreen> createState() =>
      _CreateActiveMaterialScreenState();
}

class _CreateActiveMaterialScreenState
    extends State<CreateActiveMaterialScreen> {
  late CreateMaterialController controller;
  final ImagePicker _picker = ImagePicker();

  List<XFile> images = [];

  int sessionsCount = 5;
  String dialysisMachine = 'portable';

  bool dialyzer = true;
  bool bloodTubingSets = true;
  bool dialysisNeedles = true;
  bool dialysateConcentrates = true;
  bool heparin = true;
  bool salineSolution = true;

  final TextEditingController notesController =
  TextEditingController(text: 'Kit issued for 5 days.');

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CreateMaterialController(
        doctorId: widget.doctorId,
        patientId: widget.patientId,
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CreateMaterialController>();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked != null && picked.isNotEmpty) {
      setState(() => images = picked);
    }
  }

  Future<void> submit() async {
    /// 🚨 PHOTO IS COMPULSORY
    if (images.isEmpty) {
      Get.snackbar(
        'Photo Required',
        'Please upload at least one dialysis kit photo to continue.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final id = await controller.createAndUpload(
      sessionsCount: sessionsCount,
      dialysisMachine: dialysisMachine,
      dialyzer: dialyzer,
      bloodTubingSets: bloodTubingSets,
      dialysisNeedles: dialysisNeedles,
      dialysateConcentrates: dialysateConcentrates,
      heparin: heparin,
      salineSolution: salineSolution,
      notes: notesController.text.trim(),
      imageFiles: images, // ✅ XFile list
    );

    if (id != null) {
      Get.back(result: true);
      Get.snackbar(
        'Saved Successfully',
        'Dialysis kit details have been saved.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        controller.errorMsg.value.isEmpty
            ? 'Unable to save details'
            : controller.errorMsg.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final canSubmit = images.isNotEmpty && !controller.isSubmitting.value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dialysis Kit Details'),
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🗓 TREATMENT DETAILS
            _sectionCard(
              icon: Icons.calendar_today,
              title: 'Treatment Duration',
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: sessionsCount.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of days',
                      ),
                      onChanged: (v) {
                        sessionsCount = int.tryParse(v) ?? sessionsCount;
                        notesController.text =
                        'Kit issued for $sessionsCount days.';
                      },
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: dialysisMachine,
                      decoration:
                      const InputDecoration(labelText: 'Machine type'),
                      items: ['portable', 'automated', 'other']
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.capitalizeFirst!),
                        ),
                      )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => dialysisMachine = v!),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            /// 🩺 INCLUDED SUPPLIES
            _sectionCard(
              icon: Icons.medical_services,
              title: 'Included Medical Supplies',
              child: Column(
                children: [
                  _check('Dialyzer (Filter)', dialyzer,
                          (v) => setState(() => dialyzer = v)),
                  _check('Blood Tubing Sets', bloodTubingSets,
                          (v) => setState(() => bloodTubingSets = v)),
                  _check('Dialysis Needles', dialysisNeedles,
                          (v) => setState(() => dialysisNeedles = v)),
                  _check('Dialysate Concentrates', dialysateConcentrates,
                          (v) => setState(() => dialysateConcentrates = v)),
                  _check('Heparin Injection', heparin,
                          (v) => setState(() => heparin = v)),
                  _check('Saline Solution', salineSolution,
                          (v) => setState(() => salineSolution = v)),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            /// 📝 NOTES
            _sectionCard(
              icon: Icons.notes,
              title: 'Additional Notes (Optional)',
              child: TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any special instructions',
                ),
              ),
            ),

            SizedBox(height: h * 0.025),

            /// 📸 PHOTOS (REQUIRED)
            _sectionCard(
              icon: Icons.photo_camera,
              title: 'Dialysis Kit Photos (Required)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add photo'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'At least one photo is required for verification',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (images.isNotEmpty) ...[
                    SizedBox(height: h * 0.015),
                    SizedBox(
                      height: h * 0.16,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final img = images[i];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: kIsWeb
                                    ? Image.network(
                                  img.path,
                                  width: w * 0.45,
                                  fit: BoxFit.cover,
                                )
                                    : Image.file(
                                  File(img.path),
                                  width: w * 0.45,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => images.removeAt(i)),
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.close, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: h * 0.04),

            /// ✅ SUBMIT (DISABLED UNTIL PHOTO)
            Obx(
                  () => controller.isSubmitting.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSubmit ? submit : null,
                  style: ElevatedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(vertical: h * 0.018),
                    backgroundColor: canSubmit
                        ? const Color(0xff1565C0)
                        : Colors.grey[400],
                  ),
                  child: const Text('Save & Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- UI HELPERS ----------------

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(label),
      onChanged: (v) => onChanged(v ?? false),
    );
  }
}
