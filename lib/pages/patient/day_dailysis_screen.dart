import 'dart:io';
import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/patient_panel_controller.dart';

class DayDialysisScreen extends StatefulWidget {
  final String sessionId;
  final int dayNumber;
  final String MaterialSessionId;
  final String patientId;

  const DayDialysisScreen({
    super.key,
    required this.sessionId,
    required this.dayNumber,
    required this.MaterialSessionId,
    required this.patientId
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
  Uint8List? webImage;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>();
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final padding = width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Day ${widget.dayNumber} - Dialysis Session",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: width * 0.045,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wellness Check Card
            _buildSectionCard(
              context: context,
              icon: Icons.favorite_rounded,
              title: "How are you feeling?",
              color: AppStatusColors.error,
              child: Column(
                children: [
                  _buildWellnessQuestion(
                    context,
                    "Feeling OK today?",
                    feelingOk,
                        (v) => setState(() => feelingOk = v!),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildWellnessQuestion(
                    context,
                    "Any fever?",
                    fever,
                        (v) => setState(() => fever = v!),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildTextField(
                    context: context,
                    controller: comment,
                    label: "Additional Comments",
                    hint: "Share any concerns or observations...",
                    maxLines: 3,
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Technical Parameters Card
            _buildSectionCard(
              context: context,
              icon: Icons.science_rounded,
              title: "Session Details",
              color: AppColors.darkPrimary,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: fillVolume,
                          label: "Fill Volume",
                          hint: "ml",
                          icon: Icons.water_drop_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: drainVolume,
                          label: "Drain Volume",
                          hint: "ml",
                          icon: Icons.water_drop_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: fillTime,
                          label: "Fill Time",
                          hint: "mins",
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: drainTime,
                          label: "Drain Time",
                          hint: "mins",
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  _buildTextField(
                    context: context,
                    controller: bp,
                    label: "Blood Pressure",
                    hint: "e.g., 120/80",
                    icon: Icons.monitor_heart_outlined,
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: weightPre,
                          label: "Weight (Before)",
                          hint: "kg",
                          icon: Icons.scale_outlined,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: weightPost,
                          label: "Weight (After)",
                          hint: "kg",
                          icon: Icons.scale_outlined,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: exchanges,
                          label: "Exchanges",
                          hint: "count",
                          icon: Icons.repeat_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: _buildTextField(
                          context: context,
                          controller: duration,
                          label: "Duration",
                          hint: "mins",
                          icon: Icons.access_time_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // Image Upload Card
            _buildSectionCard(
              context: context,
              icon: Icons.photo_camera_rounded,
              title: "Session Photo",
              color: AppStatusColors.info,
              child: Column(
                children: [
                  if (selectedImage != null || webImage != null)
                    Container(
                      height: height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.03),
                        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3), width: 2),
                        image: DecorationImage(
                          image: kIsWeb
                              ? MemoryImage(webImage!) as ImageProvider
                              : FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: height * 0.18,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(width * 0.03),
                        border: Border.all(
                          color: AppColors.mediumGrey.withOpacity(0.5),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: width * 0.12,
                              color: AppColors.mediumGrey,
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              "No photo added",
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: height * 0.02),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        if (kIsWeb) {
                          final bytes = await picked.readAsBytes();
                          setState(() {
                            webImage = bytes;
                          });
                        } else {
                          setState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      }
                    },
                    icon: Icon(
                        (selectedImage == null && webImage == null) ? Icons.add_a_photo : Icons.edit,
                        size: width * 0.045
                    ),
                    label: Text(
                      (selectedImage == null && webImage == null) ? "Add Photo" : "Change Photo",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppStatusColors.info,
                      side: BorderSide(color: AppStatusColors.info, width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.04),

            // Finish Button
            Obx(() {
              return controller.isLoading.value
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkPrimary,
                ),
              )
                  : SizedBox(
                width: double.infinity,
                height: height * 0.07,
                child: ElevatedButton.icon(
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
                        backgroundColor: AppStatusColors.verified,
                        colorText: AppColors.white,
                        icon: Icon(Icons.check_circle, color: AppColors.white),
                      );

                      // 2️⃣ Refresh data FIRST
                      final controller = Get.find<PatientPanelController>();
                      await controller.fetchMaterialSessionDetails(widget.MaterialSessionId);

                      Get.offNamedUntil(
                        RouteHelper.getPatientMaterialSessionDetails(
                            widget.MaterialSessionId,
                            widget.patientId
                        ),
                            (route) => route.settings.name == RouteHelper.patientMaterialSessionDetails,
                      );
                    }
                  },
                  icon: Icon(Icons.check_circle_outline_rounded, size: width * 0.06),
                  label: Text(
                    "Complete Session",
                    style: TextStyle(
                      fontSize: width * 0.042,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStatusColors.verified,
                    foregroundColor: AppColors.white,
                    elevation: 4,
                    shadowColor: AppStatusColors.verified.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: height * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.045),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(width * 0.04),
                topRight: Radius.circular(width * 0.04),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.02),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  child: Icon(icon, color: color, size: width * 0.055),
                ),
                SizedBox(width: width * 0.03),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.043,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessQuestion(BuildContext context, String question, String value, Function(String?) onChanged) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: width * 0.038,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: height * 0.012),
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                context,
                "Yes",
                "yes",
                value,
                onChanged,
                AppStatusColors.verified,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildOptionButton(
                context,
                "No",
                "no",
                value,
                onChanged,
                AppStatusColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(
      BuildContext context,
      String label,
      String optionValue,
      String currentValue,
      Function(String?) onChanged,
      Color color,
      ) {
    final isSelected = currentValue == optionValue;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () => onChanged(optionValue),
      borderRadius: BorderRadius.circular(width * 0.025),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.016),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppColors.lightGrey,
          border: Border.all(
            color: isSelected ? color : AppColors.mediumGrey.withOpacity(0.5),
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(width * 0.025),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: width * 0.045,
              ),
            if (isSelected) SizedBox(width: width * 0.015),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.darkGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: width * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: width * 0.038,
        color: AppColors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: width * 0.036,
          color: AppColors.darkGrey,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: width * 0.035,
          color: AppColors.mediumGrey,
        ),
        prefixIcon: icon != null
            ? Icon(
          icon,
          size: width * 0.05,
          color: AppColors.darkPrimary,
        )
            : null,
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(color: AppColors.mediumGrey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(
            color: AppColors.mediumGrey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.025),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.016,
        ),
      ),
    );
  }
}