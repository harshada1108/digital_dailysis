import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digitaldailysis/controllers/create_material_controller.dart';
import 'package:digitaldailysis/utils/colors.dart';

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
      imageFiles: images,
    );

    if (id != null) {
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Dialysis material created successfully',
        backgroundColor: AppColors.darkPrimary,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        controller.errorMsg.value.isEmpty
            ? 'Failed to create material'
            : controller.errorMsg.value,
        backgroundColor: AppColors.black,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.darkPrimary,
        centerTitle: true,
        title: Text(
          'Create Dialysis Material',
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              w,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: sessionsCount.toString(),
                          keyboardType: TextInputType.number,
                          decoration:
                          _inputDecoration('Sessions', Icons.event, w),
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
                          _inputDecoration('Machine', Icons.settings, w),
                          items: ['portable', 'automated', 'other']
                              .map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => dialysisMachine = v!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.02),
                  _check('Dialyzer', dialyzer, (v) => dialyzer = v),
                  _check('Blood Tubing Sets', bloodTubingSets,
                          (v) => bloodTubingSets = v),
                  _check('Dialysis Needles', dialysisNeedles,
                          (v) => dialysisNeedles = v),
                  _check('Dialysate Concentrates', dialysateConcentrates,
                          (v) => dialysateConcentrates = v),
                  _check('Heparin', heparin, (v) => heparin = v),
                  _check('Saline Solution', salineSolution,
                          (v) => salineSolution = v),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration:
                    _inputDecoration('Optional notes', Icons.note, w),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            _card(
              w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material Images',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                    ),
                    icon: Icon(Icons.photo, color: AppColors.white),
                    label: Text(
                      'Pick Images',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  if (images.isNotEmpty)
                    SizedBox(
                      height: h * 0.18,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: w * 0.03),
                        itemBuilder: (_, i) {
                          final img = images[i];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(w * 0.03),
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
                                top: w * 0.015,
                                right: w * 0.015,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => images.removeAt(i)),
                                  child: CircleAvatar(
                                    radius: w * 0.035,
                                    backgroundColor: AppColors.white,
                                    child: Icon(
                                      Icons.close,
                                      size: w * 0.04,
                                      color: AppColors.black,
                                    ),
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

            SizedBox(height: h * 0.05),

            Obx(
                  () => controller.isSubmitting.value
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkPrimary,
                ),
              )
                  : SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.03),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _card(double w, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGrey.withOpacity(0.3),
            blurRadius: w * 0.02,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => setState(() => onChanged(v ?? false)),
      title: Text(
        label,
        style: TextStyle(color: AppColors.black),
      ),
      activeColor: AppColors.darkPrimary,
      contentPadding: EdgeInsets.zero,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, double w) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.darkPrimary),
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        borderSide: BorderSide(
          color: AppColors.darkPrimary,
          width: 2,
        ),
      ),
    );
  }
}
