import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_panel_controller.dart';
import 'day_details_page.dart';

class MaterialSessionDetailsPage extends StatelessWidget {
  final String sessionId;
  final String patientId;

  const MaterialSessionDetailsPage({
    super.key,
    required this.sessionId,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientPanelController>(tag: patientId);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Material Session Details"),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final session = controller.summary.value!.materialSessions
            .firstWhere((s) => s.materialSessionId == sessionId);

        final stats = _calculateStats(session);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(session, screenWidth),
              _buildStatsCard(stats, screenWidth),
              _buildMaterialsSection(session, screenWidth),
              if (session.materialImages != null && session.materialImages.isNotEmpty)
                _buildMaterialImagesSection(session.materialImages, screenWidth),
              _buildDaysSection(session, controller, screenWidth),
              if (session.status != "acknowledged")
                _buildAcknowledgeButton(context, controller, sessionId, screenWidth, screenHeight),
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
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = "Materials Acknowledged";
        break;
      case "active":
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        statusText = "Session Active";
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = "Awaiting Acknowledgment";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: Colors.white, size: screenWidth * 0.08),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            "Created: ${_formatDate(session.createdAt)}",
            style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.035),
          ),
          if (session.acknowledgedAt != null)
            Text(
              "Acknowledged: ${_formatDate(session.acknowledgedAt)}",
              style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.035),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blue, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Session Statistics",
                    style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
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
                      Colors.blue,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: _buildStatItem(
                      "Completed",
                      "${stats['completed']}",
                      Icons.check_circle,
                      Colors.green,
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
                      Colors.orange,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: _buildStatItem(
                      "Pending",
                      "${stats['pending']}",
                      Icons.hourglass_empty,
                      Colors.grey,
                      screenWidth,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              LinearProgressIndicator(
                value: stats['total'] > 0 ? stats['completed'] / stats['total'] : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: screenWidth * 0.02,
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                "Progress: ${stats['total'] > 0 ? ((stats['completed'] / stats['total']) * 100).toStringAsFixed(0) : 0}%",
                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.07),
          SizedBox(height: screenWidth * 0.02),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[600]),
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
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.blue, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      "Materials Provided",
                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              _buildMaterialChip(
                "Dialysis Machine",
                materials.dialysisMachine.toUpperCase(),
                Colors.blue,
                screenWidth,
              ),
              SizedBox(height: screenWidth * 0.02),
              Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenWidth * 0.02,
                children: [
                  if (materials.dialyzer)
                    _buildMaterialChip("Dialyzer", "✓", Colors.green, screenWidth),
                  if (materials.bloodTubingSets)
                    _buildMaterialChip("Blood Tubing Sets", "✓", Colors.green, screenWidth),
                  if (materials.dialysisNeedles)
                    _buildMaterialChip("Dialysis Needles", "✓", Colors.green, screenWidth),
                  if (materials.dialysateConcentrates)
                    _buildMaterialChip("Dialysate Concentrates", "✓", Colors.green, screenWidth),
                  if (materials.heparin)
                    _buildMaterialChip("Heparin", "✓", Colors.green, screenWidth),
                  if (materials.salineSolution)
                    _buildMaterialChip("Saline Solution", "✓", Colors.green, screenWidth),
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
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
            ),
          ),
          if (value != "✓") ...[
            SizedBox(width: screenWidth * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenWidth * 0.005,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.03,
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
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library, color: Colors.blue, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Material Images",
                    style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: screenWidth * 0.02,
                  mainAxisSpacing: screenWidth * 0.02,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imageUrl = images[index]?.imageUrl ??
                      images[index]?['imageUrl'] ?? '';

                  if (imageUrl.isEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Icon(Icons.image_not_supported, size: screenWidth * 0.08),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: screenWidth * 0.08),
                        );
                      },
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
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event_note, color: Colors.blue, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Dialysis Days",
                    style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
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
    IconData statusIcon;
    String statusText;

    switch (day.status) {
      case "completed":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = "Completed & Verified";
        break;
      case "active":
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = "Awaiting Verification";
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        statusText = canStart ? "Ready to Start" : "Locked";
    }

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: InkWell(
        onTap: () {
          if (session.status == "acknowledged") {
            Get.to(
                  () => DayDetailsPage(
                materialSessionId: session.materialSessionId,
                dayNumber: day.dayNumber,
                patientId: patientId,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${day.dayNumber}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
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
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Row(
                      children: [
                        Icon(statusIcon, size: screenWidth * 0.04, color: statusColor),
                        SizedBox(width: screenWidth * 0.01),
                        Flexible(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                session.status == "acknowledged"
                    ? Icons.arrow_forward_ios
                    : Icons.lock,
                color: statusColor,
                size: screenWidth * 0.05,
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
              title: Text("Acknowledge Materials"),
              content: Text(
                "Have you received and verified all the materials for this session?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: Text("Confirm"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final ok = await controller.acknowledgeSession(sessionId);
            if (ok) {
              Get.back();
              Get.snackbar(
                "Success",
                "Materials Acknowledged Successfully",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          }
        },
        icon: Icon(Icons.check),
        label: Text("Acknowledge Materials"),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          textStyle: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(dynamic session) {
    int total = session.days.length;
    int completed = session.days.where((d) => d.status == "completed").length;
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
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateValue.toString();
    }
  }
}