// lib/pages/doctor/material_session_details.dart


import 'package:digitaldailysis/controllers/doctor_material_controller.dart';
import 'package:digitaldailysis/controllers/patient_info_controller.dart';
import 'package:digitaldailysis/pages/doctor/doc_day_detail_page.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';
import 'package:intl/intl.dart';



class MaterialSessionDetailScreen extends StatelessWidget {

  final patientId;
  const MaterialSessionDetailScreen({super.key ,  required this.patientId});



  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientInfoController>();
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;


    return Obx(() {
      final materialSession = controller.materialSessionDetails.value;

      if (materialSession == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }


      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: _buildBody(context, materialSession, w, h),
      );
    });
  }




  // ================= SMALL UI POLISH =================
      Widget _buildBody(
      BuildContext context,
      var materialSession,
      double w,
      double h,
    ) {
    final statusColor = _getStatusColor(materialSession.status);
    final statusIcon = _getStatusIcon(materialSession.status);


    return CustomScrollView(

        slivers: [
          // ================= HEADER =================
          SliverAppBar(
            pinned: true,
            expandedHeight: h * 0.24,
            backgroundColor: statusColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.all(w * 0.05),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(w * 0.035),
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimary,
                        borderRadius: BorderRadius.circular(w * 0.035),
                      ),
                      child: Icon(
                        statusIcon,
                        color: Colors.white,
                        size: w * 0.085,
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dialysis Session',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.03,
                              vertical: h * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(w * 0.04),
                            ),
                            child: Text(
                              materialSession.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: w * 0.032,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= BODY =================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(w * 0.045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- META CARDS ----------
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateCard(
                          'Created',
                          materialSession.createdAt,
                          Icons.event_available,
                          Colors.blue, // kept
                          w,
                          h,
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      Expanded(
                        child: _buildInfoCard(
                          'Sessions',
                          '${materialSession.plannedSessions}',
                          Icons.repeat,
                          Colors.purple, // kept
                          w,
                          h,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.03),

                  // ---------- PROGRESS ----------
                  _buildProgressCard(w, h,materialSession),

                  SizedBox(height: h * 0.035),

                  // ---------- MATERIALS ----------
                  _buildSectionTitle(
                    'Medical Materials',
                    Icons.medical_services,
                    Colors.green,
                    w,
                  ),
                  SizedBox(height: h * 0.015),
                  _buildMaterialsCard(w, h, materialSession),

                  SizedBox(height: h * 0.035),

                  // ---------- IMAGES ----------
                  if (materialSession.materialImages.isNotEmpty) ...[
                    _buildSectionTitle(
                      'Session Images',
                      Icons.photo_library,
                      Colors.orange,
                      w,
                    ),
                    SizedBox(height: h * 0.015),
                    _buildImagesSection(w, h, materialSession),
                    SizedBox(height: h * 0.035),
                  ],

                  // ---------- DAYS ----------
                  _buildSectionTitle(
                    'Treatment Days',
                    Icons.calendar_month,
                    Colors.indigo,
                    w,
                  ),
                  SizedBox(height: h * 0.015),
                  ...materialSession.days.map(
                        (d) => _buildDayCard(d, d.dayNumber - 1, w, h,materialSession),
                  ),

                  SizedBox(height: h * 0.03),
                ],
              ),
            ),
          ),
        ],
      );
    }
  Widget _buildDateCard(
      String label,
      DateTime? date,
      IconData icon,
      Color color,
      double w,
      double h,
      ) {
    final formatted = date != null
        ? _formatDateBeautiful(date)
        : 'Not Available';

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Icon(icon, color: color, size: w * 0.06),
          ),
          SizedBox(height: h * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.032,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: h * 0.005),
          Text(
            formatted,
            style: TextStyle(
              fontSize: w * 0.036,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, Color color, double w) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.025),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(w * 0.03),
          ),
          child: Icon(icon, color: color, size: w * 0.055),
        ),
        SizedBox(width: w * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }




  Widget _buildInfoCard(String label, String value, IconData icon, Color color, double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Icon(icon, color: color, size: w * 0.06),
          ),
          SizedBox(height: h * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.032,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: h * 0.005),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double w, double h , var materialSession) {

    final total = materialSession.days.length;
    final verified = materialSession.days.where((d) => d.status.toLowerCase() == 'verified').length;
    final completed = materialSession.days.where((d) => d.status.toLowerCase() == 'completed').length;
    final progress = total > 0 ? verified / total : 0.0;

    return Container(
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.05), Colors.purple.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session Progress',
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          ClipRRect(
            borderRadius: BorderRadius.circular(w * 0.02),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: h * 0.012,
            ),
          ),
          SizedBox(height: h * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('Total', total, Colors.blue, w),
              _buildProgressStat('Verified', verified, Colors.green, w),
              _buildProgressStat('Completed', completed, Colors.orange, w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, int value, Color color, double w) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: w * 0.055,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.032,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Widget _buildSectionTitle(String title, IconData icon, Color color, double w) {
  //   return Row(
  //     children: [
  //       Container(
  //         padding: EdgeInsets.all(w * 0.025),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
  //           ),
  //           borderRadius: BorderRadius.circular(w * 0.025),
  //         ),
  //         child: Icon(icon, color: color, size: w * 0.06),
  //       ),
  //       SizedBox(width: w * 0.025),
  //       Text(
  //         title,
  //         style: TextStyle(
  //           fontSize: w * 0.048,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.grey[800],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildMaterialsCard(double w, double h , var materialSession) {
    final materials = materialSession.materials;
    final materialList = [
      {
        'label': 'Dialysis Machine',
        'value': materials.dialysisMachine.toUpperCase(),
        'icon': Icons.precision_manufacturing,
        'show': true
      },
      {'label': 'Dialyzer', 'icon': Icons.filter_alt, 'show': materials.dialyzer},
      {'label': 'Blood Tubing Sets', 'icon': Icons.cable, 'show': materials.bloodTubingSets},
      {'label': 'Dialysis Needles', 'icon': Icons.coronavirus_outlined, 'show': materials.dialysisNeedles},
      {'label': 'Concentrates', 'icon': Icons.water_drop, 'show': materials.dialysateConcentrates},
      {'label': 'Heparin', 'icon': Icons.medication, 'show': materials.heparin},
      {'label': 'Saline Solution', 'icon': Icons.local_drink, 'show': materials.salineSolution},
    ].where((m) => m['show'] as bool).toList();

    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: materialList.asMap().entries.map((entry) {
          final index = entry.key;
          final material = entry.value;
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.035),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.withOpacity(0.05), Colors.green.withOpacity(0.02)],
                  ),
                  borderRadius: BorderRadius.circular(w * 0.03),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(w * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(w * 0.02),
                      ),
                      child: Icon(
                        material['icon'] as IconData,
                        color: Colors.green[700],
                        size: w * 0.055,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material['label'] as String,
                            style: TextStyle(
                              fontSize: w * 0.038,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (material.containsKey('value')) ...[
                            SizedBox(height: h * 0.003),
                            Text(
                              material['value'] as String,
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.green[600], size: w * 0.055),
                  ],
                ),
              ),
              if (index < materialList.length - 1) SizedBox(height: h * 0.01),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagesSection(double w, double h, var materialSession) {
    return Container(
      height: h * 0.22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: materialSession.materialImages.length,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
        itemBuilder: (_, i) {
          final img = materialSession.materialImages[i];
          return GestureDetector(
            onTap: () => _showImageDialog(img.imageUrl, i, w, h),
            child: Hero(
              tag: 'session_image_$i',
              child: Container(
                width: w * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.04),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(img.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: w * 0.03,
                        right: w * 0.03,
                        child: Container(
                          padding: EdgeInsets.all(w * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(w * 0.02),
                          ),
                          child: Icon(Icons.zoom_in, size: w * 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCard(DayItem day, int index, double w, double h, var materialSession) {
    Color dayStatusColor = _getStatusColor(day.status);
    IconData dayStatusIcon = _getStatusIcon(day.status);
    final completedDate = day.completedAt != null ? _formatDateBeautiful(day.completedAt!) : null;

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, dayStatusColor.withOpacity(0.03)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: dayStatusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: dayStatusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Get.to(
                  () => DayDetailPage(day: day),
            );

            if (result == true) {
              // re-fetch updated material session details
              final controller = Get.find<PatientInfoController>();

              await controller.fetchMaterialSessionDetailsByDoc(
                materialSessionId: materialSession.materialSessionId,
                patientId: patientId,
              );
            }
          },

          borderRadius: BorderRadius.circular(w * 0.04),
          child: Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Row(
              children: [
                Container(
                  width: w * 0.16,
                  height: w * 0.16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [dayStatusColor, dayStatusColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(w * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: dayStatusColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.dayNumber}',
                        style: TextStyle(
                          fontSize: w * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'DAY',
                        style: TextStyle(
                          fontSize: w * 0.025,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Treatment Day ${day.dayNumber}',
                        style: TextStyle(
                          fontSize: w * 0.042,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: h * 0.008),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.005),
                        decoration: BoxDecoration(
                          color: dayStatusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(w * 0.02),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(dayStatusIcon, size: w * 0.035, color: dayStatusColor),
                            SizedBox(width: w * 0.015),
                            Text(
                              day.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: w * 0.03,
                                color: dayStatusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (completedDate != null) ...[
                        SizedBox(height: h * 0.008),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: w * 0.032, color: Colors.grey[600]),
                            SizedBox(width: w * 0.015),
                            Text(
                              completedDate,
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (day.images.isNotEmpty) ...[
                        SizedBox(height: h * 0.005),
                        Row(
                          children: [
                            Icon(Icons.photo_camera, size: w * 0.032, color: Colors.grey[600]),
                            SizedBox(width: w * 0.015),
                            Text(
                              '${day.images.length} ${day.images.length == 1 ? 'photo' : 'photos'}',
                              style: TextStyle(fontSize: w * 0.032, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: dayStatusColor, size: w * 0.045),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl, int index, double w, double h) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Hero(
                  tag: 'session_image_$index',
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: h * 0.02,
              right: w * 0.02,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateBeautiful(DateTime date) {
    final local = date.toLocal();
    return DateFormat('d MMM yyyy, h:mm a').format(local);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.grey;
      case 'verified':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'acknowledged':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_circle;
      case 'verified':
        return Icons.verified;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'acknowledged':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}