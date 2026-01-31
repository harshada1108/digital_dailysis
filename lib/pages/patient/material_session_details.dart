import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/patient_panel_controller.dart';
import 'day_details_page.dart';

// Add these status colors to your AppColors class


class MaterialSessionDetailsPage extends StatefulWidget {
  final String sessionId;
  final String patientId;

  const MaterialSessionDetailsPage({
    super.key,
    required this.sessionId,
    required this.patientId,
  });

  @override
  State<MaterialSessionDetailsPage> createState() => _MaterialSessionDetailsPageState();
}

class _MaterialSessionDetailsPageState extends State<MaterialSessionDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<PatientPanelController>(tag: widget.patientId);
      controller.fetchMaterialSessionDetails(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>(tag: widget.patientId);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          onPressed: () {
            Get.offNamed(
              RouteHelper.getPatientHomeScreen(widget.patientId),
            );
          },
        ),
        title: const Text(
          "Material Session Details",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.darkPrimary,
            ),
          );
        }

        final session = controller.materialSessionDetails.value;

        if (session == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppStatusColors.error),
                SizedBox(height: 16),
                Text(
                  "Session not found",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.fetchSummary();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text("Refresh"),
                ),
              ],
            ),
          );
        }

        final stats = _calculateStats(session);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(session, screenWidth),
              _buildStatsCard(stats, screenWidth),
              _buildMaterialsSection(session, screenWidth),
              if (session.materialSession.materialImages != null && session.materialSession.materialImages.isNotEmpty)
                _buildMaterialImagesSection(session.materialSession.materialImages, screenWidth),
              _buildDaysSection(session, controller, screenWidth),
              if (session.materialSession.status != "acknowledged")
                _buildAcknowledgeButton(context, controller, widget.sessionId, screenWidth, screenHeight),
              SizedBox(height: screenWidth * 0.04),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusHeader(dynamic session, double screenWidth) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (session.status) {
      case "acknowledged":
        statusColor = AppStatusColors.verified;
        statusIcon = Icons.check_circle;
        statusText = "Materials Acknowledged";
        break;
      case "active":
        statusColor = AppStatusColors.info;
        statusIcon = Icons.pending;
        statusText = "Session Active";
        break;
      default:
        statusColor = AppStatusColors.warning;
        statusIcon = Icons.warning_amber_rounded;
        statusText = "Awaiting Acknowledgment";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkPrimary, AppColors.darkPrimary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
              border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: screenWidth * 0.055),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  statusText,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          _buildInfoRow(
            Icons.calendar_today,
            "Created",
            _formatDate(session.createdAt),
            screenWidth,
          ),
          if (session.acknowledgedAt != null) ...[
            SizedBox(height: screenWidth * 0.02),
            _buildInfoRow(
              Icons.check_circle_outline,
              "Acknowledged",
              _formatDate(session.acknowledgedAt),
              screenWidth,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, double screenWidth) {
    return Row(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: screenWidth * 0.045),
        SizedBox(width: screenWidth * 0.02),
        Text(
          "$label: ",
          style: TextStyle(
            color: AppColors.white.withOpacity(0.9),
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.bar_chart, color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Session Statistics",
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      "Total Days",
                      "${stats['total']}",
                      Icons.calendar_today,
                      AppColors.darkPrimary,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildStatItem(
                      "Completed",
                      "${stats['completed']}",
                      Icons.check_circle,
                      AppStatusColors.verified,
                      screenWidth,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      "Active",
                      "${stats['active']}",
                      Icons.pending,
                      AppStatusColors.active,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildStatItem(
                      "Pending",
                      "${stats['pending']}",
                      Icons.hourglass_empty,
                      AppStatusColors.pending,
                      screenWidth,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: LinearProgressIndicator(
                  value: stats['total'] > 0 ? stats['completed'] / stats['total'] : 0,
                  backgroundColor: AppColors.lightGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(AppStatusColors.verified),
                  minHeight: screenWidth * 0.025,
                ),
              ),
              SizedBox(height: screenWidth * 0.025),
              Text(
                "Progress: ${stats['total'] > 0 ? ((stats['completed'] / stats['total']) * 100).toStringAsFixed(0) : 0}% Complete",
                style: TextStyle(
                  fontSize: screenWidth * 0.037,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.08),
          SizedBox(height: screenWidth * 0.02),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(dynamic session, double screenWidth) {
    final materials = session.materials;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.medical_services, color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      "Materials Provided",
                      style: TextStyle(
                        fontSize: screenWidth * 0.048,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              _buildMaterialChip(
                "Dialysis Machine",
                materials.dialysisMachine.toUpperCase(),
                AppColors.darkPrimary,
                screenWidth,
              ),
              SizedBox(height: screenWidth * 0.03),
              Wrap(
                spacing: screenWidth * 0.025,
                runSpacing: screenWidth * 0.025,
                children: [
                  if (materials.dialyzer)
                    _buildMaterialChip("Dialyzer", "✓", AppStatusColors.verified, screenWidth),
                  if (materials.bloodTubingSets)
                    _buildMaterialChip("Blood Tubing Sets", "✓", AppStatusColors.verified, screenWidth),
                  if (materials.dialysisNeedles)
                    _buildMaterialChip("Dialysis Needles", "✓", AppStatusColors.verified, screenWidth),
                  if (materials.dialysateConcentrates)
                    _buildMaterialChip("Dialysate Concentrates", "✓", AppStatusColors.verified, screenWidth),
                  if (materials.heparin)
                    _buildMaterialChip("Heparin", "✓", AppStatusColors.verified, screenWidth),
                  if (materials.salineSolution)
                    _buildMaterialChip("Saline Solution", "✓", AppStatusColors.verified, screenWidth),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialChip(String label, String value, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: screenWidth * 0.025,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.06),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value == "✓")
            Icon(Icons.check_circle, color: color, size: screenWidth * 0.045),
          if (value == "✓") SizedBox(width: screenWidth * 0.015),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.036,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          if (value != "✓") ...[
            SizedBox(width: screenWidth * 0.025),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025,
                vertical: screenWidth * 0.008,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialImagesSection(List<dynamic> images, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.photo_library, color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Material Images",
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: screenWidth * 0.025,
                  mainAxisSpacing: screenWidth * 0.025,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imageUrl = images[index]?.imageUrl ??
                      images[index]?['imageUrl'] ?? '';

                  if (imageUrl.isEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(color: AppColors.mediumGrey.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: screenWidth * 0.08,
                        color: AppColors.mediumGrey,
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey, width: 2),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.lightGrey,
                            child: Icon(
                              Icons.broken_image,
                              size: screenWidth * 0.08,
                              color: AppColors.mediumGrey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysSection(dynamic session, PatientPanelController controller, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 3,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Icon(Icons.event_note, color: AppColors.darkPrimary, size: screenWidth * 0.06),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Dialysis Days",
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              ...session.days.map<Widget>((day) {
                final canStart = _canStartDay(session, day.dayNumber);
                return _buildDayTile(session, day, canStart, screenWidth);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayTile(dynamic session, dynamic day, bool canStart, double screenWidth) {
    Color statusColor;
    Color bgColor;
    IconData statusIcon;
    String statusText;

    switch (day.status) {
      case "verified":
        statusColor = AppStatusColors.verified;
        bgColor = AppStatusColors.verified.withOpacity(0.1);
        statusIcon = Icons.verified;
        statusText = "Completed & Verified";
        break;
      case "completed":
        statusColor = AppStatusColors.info;
        bgColor = AppStatusColors.info.withOpacity(0.1);
        statusIcon = Icons.check_circle;
        statusText = "Awaiting Doctor Verification";
        break;
      case "active":
        statusColor = AppStatusColors.active;
        bgColor = AppStatusColors.active.withOpacity(0.1);
        statusIcon = Icons.pending;
        statusText = "Dialysis Started";
        break;
      default:
        statusColor = canStart ? AppColors.darkPrimary : AppStatusColors.locked;
        bgColor = canStart ? AppColors.darkPrimary.withOpacity(0.08) : AppStatusColors.locked.withOpacity(0.08);
        statusIcon = canStart ? Icons.play_circle_outline : Icons.lock;
        statusText = canStart ? "Ready to Start" : "Locked";
    }

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: InkWell(
        onTap: () async {
          if (session.status == "acknowledged") {
            await Get.to(
                  () => DayDetailsPage(
                materialSessionId: session.materialSessionId,
                dayNumber: day.dayNumber,
                patientId: widget.patientId,
              ),
            );
            // Refresh data when coming back
            final controller = Get.find<PatientPanelController>(tag: widget.patientId);
            controller.fetchMaterialSessionDetails(widget.sessionId);
          }
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.14,
                height: screenWidth * 0.14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "${day.dayNumber}",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Day ${day.dayNumber}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.015),
                    Row(
                      children: [
                        Icon(statusIcon, size: screenWidth * 0.042, color: statusColor),
                        SizedBox(width: screenWidth * 0.015),
                        Flexible(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  session.status == "acknowledged"
                      ? Icons.arrow_forward_ios
                      : Icons.lock_outline,
                  color: statusColor,
                  size: screenWidth * 0.045,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcknowledgeButton(
      BuildContext context, PatientPanelController controller, String sessionId,
      double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              title: Text(
                "Acknowledge Materials",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              content: Text(
                "Have you received and verified all the materials for this session?",
                style: TextStyle(color: AppColors.darkGrey),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  child: Text("Confirm"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final ok = await controller.acknowledgeSession(sessionId);
            if (ok) {
              // Refresh the session details after acknowledgment
              await controller.fetchMaterialSessionDetails(widget.sessionId);
              Get.snackbar(
                "Success",
                "Materials Acknowledged Successfully",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppStatusColors.verified,
                colorText: AppColors.white,
                icon: Icon(Icons.check_circle, color: AppColors.white),
              );
            }
          }
        },
        icon: Icon(Icons.check_circle, size: screenWidth * 0.055),
        label: Text(
          "Acknowledge Materials",
          style: TextStyle(
            fontSize: screenWidth * 0.042,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(dynamic session) {
    int total = session.days.length;
    int completed = session.days.where((d) => d.status == "verified").length;
    int active = session.days.where((d) => d.status == "active").length;
    int pending = session.days.where((d) => d.status == "pending").length;

    return {
      'total': total,
      'completed': completed,
      'active': active,
      'pending': pending,
    };
  }

  bool _canStartDay(dynamic session, int dayNumber) {
    if (dayNumber == 1) return true;

    try {
      final previousDay = session.days.firstWhere(
            (d) => d.dayNumber == dayNumber - 1,
      );
      return previousDay.status != "pending";
    } catch (e) {
      return false;
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    try {
      DateTime date;
      if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'N/A';
      }

      // Format: Dec 24, 2025 at 2:30 PM
      return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
    } catch (e) {
      return dateValue.toString();
    }
  }
}