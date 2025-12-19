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
  TextEditingController(text: 'Kit for 5 days issued.');

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
    if (picked != null) {
      setState(() => images = picked);
    }
  }

  Future<void> submit() async {
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
      imageFiles: images,  // ✅ Pass XFile objects directly, not paths
    );

    if (id != null) {
      Get.back(result: true);
      Get.snackbar('Success', 'Dialysis material created successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Error', controller.errorMsg.value.isEmpty
          ? 'Failed to create material'
          : controller.errorMsg.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Dialysis Material'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1E88E5), Color(0xff1565C0)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: sessionsCount.toString(),
                          keyboardType: TextInputType.number,
                          decoration:
                          const InputDecoration(labelText: 'Sessions'),
                          onChanged: (v) {
                            sessionsCount = int.tryParse(v) ?? sessionsCount;
                            notesController.text =
                            'Kit for $sessionsCount days issued.';
                          },
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: dialysisMachine,
                          decoration:
                          const InputDecoration(labelText: 'Machine'),
                          items: ['portable', 'automated', 'other']
                              .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => dialysisMachine = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _check('Dialyzer', dialyzer, (v) => setState(() => dialyzer = v)),
                  _check('Blood Tubing Sets', bloodTubingSets,
                          (v) => setState(() => bloodTubingSets = v)),
                  _check('Dialysis Needles', dialysisNeedles,
                          (v) => setState(() => dialysisNeedles = v)),
                  _check('Dialysate Concentrates', dialysateConcentrates,
                          (v) => setState(() => dialysateConcentrates = v)),
                  _check('Heparin', heparin, (v) => setState(() => heparin = v)),
                  _check('Saline Solution', salineSolution,
                          (v) => setState(() => salineSolution = v)),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notes',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration:
                    const InputDecoration(hintText: 'Optional notes'),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Material Images',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: h * 0.01),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.photo),
                    label: const Text('Pick Images'),
                  ),
                  SizedBox(height: h * 0.015),
                  if (images.isNotEmpty)
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
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.network(img.path,
                                    width: w * 0.45, fit: BoxFit.cover)
                                    : Image.file(File(img.path),
                                    width: w * 0.45, fit: BoxFit.cover),
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
              ),
            ),

            SizedBox(height: h * 0.04),

            Obx(() => controller.isSubmitting.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: h * 0.018),
              ),
              child: const Text('Submit'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: child,
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      value: value,
      title: Text(label),
      onChanged: (v) => onChanged(v ?? false),
    );
  }
}
