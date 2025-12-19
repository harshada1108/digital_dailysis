// lib/pages/doctor/material_session_details.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';

class MaterialSessionDetailScreen extends StatelessWidget {
  final MaterialSession materialSession;
  const MaterialSessionDetailScreen({Key? key, required this.materialSession}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final created = materialSession.createdAt?.toLocal();

    Color statusColor = _getStatusColor(materialSession.status);
    IconData statusIcon = _getStatusIcon(materialSession.status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Beautiful gradient app bar
          SliverAppBar(
            expandedHeight: h * 0.22,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [statusColor.withOpacity(0.8), statusColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(w * 0.035),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(w * 0.03),
                              ),
                              child: Icon(statusIcon, color: Colors.white, size: w * 0.08),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Session',
                                    style: TextStyle(
                                      fontSize: w * 0.04,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.003),
                                  Text(
                                    materialSession.materialSessionId.length > 12
                                        ? '${materialSession.materialSessionId.substring(0, 12)}...'
                                        : materialSession.materialSessionId,
                                    style: TextStyle(
                                      fontSize: w * 0.042,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: h * 0.005),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.005),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(w * 0.02),
                                    ),
                                    child: Text(
                                      materialSession.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: w * 0.032,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Info Cards
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard('Created', created != null ? '${created.day}/${created.month}/${created.year}\n${created.hour}:${created.minute.toString().padLeft(2, '0')}' : 'N/A', Icons.calendar_today, Colors.blue, w, h)),
                      SizedBox(width: w * 0.03),
                      Expanded(child: _buildInfoCard('Planned', '${materialSession.plannedSessions}\nSessions', Icons.event_repeat, Colors.purple, w, h)),
                    ],
                  ),

                  SizedBox(height: h * 0.025),

                  // Materials Section
                  _buildSectionHeader('Medical Materials', Icons.medical_services, Colors.green, w, h),
                  SizedBox(height: h * 0.015),
                  _buildMaterialsCard(w, h),

                  SizedBox(height: h * 0.025),

                  // Images Section
                  if (materialSession.materialImages.isNotEmpty) ...[
                    _buildSectionHeader('Session Images', Icons.photo_library, Colors.orange, w, h),
                    SizedBox(height: h * 0.015),
                    _buildImagesSection(w, h),
                    SizedBox(height: h * 0.025),
                  ],

                  // Days Section
                  _buildSectionHeader('Treatment Days', Icons.view_day, Colors.indigo, w, h),
                  SizedBox(height: h * 0.015),
                  ...materialSession.days.map((d) => _buildDayCard(d, w, h)).toList(),

                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color, double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(w * 0.025),
            ),
            child: Icon(icon, color: color, size: w * 0.065),
          ),
          SizedBox(height: h * 0.012),
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
              fontSize: w * 0.038,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, double w, double h) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.02),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(w * 0.02),
          ),
          child: Icon(icon, color: color, size: w * 0.055),
        ),
        SizedBox(width: w * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.048,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsCard(double w, double h) {
    final materials = materialSession.materials;
    final materialList = [
      {'label': 'Machine: ${materials.dialysisMachine}', 'icon': Icons.precision_manufacturing, 'show': true},
      {'label': 'Dialyzer', 'icon': Icons.filter_alt, 'show': materials.dialyzer},
      {'label': 'Blood Tubing Sets', 'icon': Icons.cable, 'show': materials.bloodTubingSets},
      {'label': 'Dialysis Needles', 'icon': Icons.coronavirus, 'show': materials.dialysisNeedles},
      {'label': 'Concentrates', 'icon': Icons.water_drop, 'show': materials.dialysateConcentrates},
      {'label': 'Heparin', 'icon': Icons.medication, 'show': materials.heparin},
      {'label': 'Saline Solution', 'icon': Icons.local_drink, 'show': materials.salineSolution},
    ].where((m) => m['show'] as bool).toList();

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: materialList.map((material) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: h * 0.01),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.022),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(w * 0.02),
                  ),
                  child: Icon(material['icon'] as IconData, color: Colors.green[700], size: w * 0.05),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Text(
                    material['label'] as String,
                    style: TextStyle(
                      fontSize: w * 0.038,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green[600], size: w * 0.05),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagesSection(double w, double h) {
    return Container(
      height: h * 0.2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: materialSession.materialImages.length,
        separatorBuilder: (_, __) => SizedBox(width: w * 0.03),
        itemBuilder: (_, i) {
          final img = materialSession.materialImages[i];
          return GestureDetector(
            onTap: () {
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(w * 0.04),
                        child: Image.network(img.imageUrl, fit: BoxFit.contain),
                      ),
                      SizedBox(height: h * 0.02),
                      ElevatedButton.icon(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close),
                        label: Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.015),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.06)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'image_$i',
              child: Container(
                width: w * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.04),
                  child: Image.network(img.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayCard(DayItem day, double w, double h) {
    Color dayStatusColor = _getStatusColor(day.status);
    IconData dayStatusIcon = _getStatusIcon(day.status);

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.015),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: dayStatusColor.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.dialog(DayDetailDialog(day: day)),
          borderRadius: BorderRadius.circular(w * 0.04),
          child: Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Row(
              children: [
                Container(
                  width: w * 0.14,
                  height: w * 0.14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [dayStatusColor.withOpacity(0.2), dayStatusColor.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.dayNumber}',
                        style: TextStyle(
                          fontSize: w * 0.06,
                          fontWeight: FontWeight.bold,
                          color: dayStatusColor,
                        ),
                      ),
                      Text(
                        'DAY',
                        style: TextStyle(
                          fontSize: w * 0.025,
                          fontWeight: FontWeight.w600,
                          color: dayStatusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: w * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${day.dayNumber}',
                        style: TextStyle(
                          fontSize: w * 0.044,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      Row(
                        children: [
                          Icon(dayStatusIcon, size: w * 0.038, color: dayStatusColor),
                          SizedBox(width: w * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.003),
                            decoration: BoxDecoration(
                              color: dayStatusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(w * 0.015),
                            ),
                            child: Text(
                              day.status,
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: dayStatusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (day.images.isNotEmpty) ...[
                            SizedBox(width: w * 0.02),
                            Icon(Icons.photo_camera, size: w * 0.038, color: Colors.grey[500]),
                            SizedBox(width: w * 0.01),
                            Text(
                              '${day.images.length}',
                              style: TextStyle(fontSize: w * 0.032, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: w * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

class DayDetailDialog extends StatelessWidget {
  final DayItem day;
  const DayDetailDialog({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    Color statusColor = _getStatusColor(day.status);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: h * 0.85),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.06),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.8), statusColor],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(w * 0.06),
                  topRight: Radius.circular(w * 0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: w * 0.14,
                    height: w * 0.14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(w * 0.03),
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
                            fontSize: w * 0.026,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: w * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${day.dayNumber}',
                          style: TextStyle(
                            fontSize: w * 0.052,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: h * 0.005),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.004),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(w * 0.02),
                          ),
                          child: Text(
                            day.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: w * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(w * 0.02),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.white, size: w * 0.065),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completion Info with beautiful design
                    if (day.completedAt != null) ...[
                      Container(
                        padding: EdgeInsets.all(w * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(w * 0.035),
                          border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(w * 0.025),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(w * 0.02),
                              ),
                              child: Icon(Icons.check_circle, color: Colors.green[700], size: w * 0.06),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Completed At',
                                    style: TextStyle(
                                      fontSize: w * 0.034,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.004),
                                  Text(
                                    _formatDateTime(day.completedAt!),
                                    style: TextStyle(
                                      fontSize: w * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.025),
                    ],

                    // Treatment Parameters with beautiful design
                    if (day.parameters != null && day.parameters!.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(w * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(w * 0.02),
                            ),
                            child: Icon(Icons.analytics, color: Colors.blue[700], size: w * 0.055),
                          ),
                          SizedBox(width: w * 0.025),
                          Text(
                            'Treatment Parameters',
                            style: TextStyle(
                              fontSize: w * 0.048,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.015),
                      Container(
                        padding: EdgeInsets.all(w * 0.045),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(w * 0.035),
                          border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildParametersList(day.parameters!, w, h),
                        ),
                      ),
                      SizedBox(height: h * 0.025),
                    ],

                    // Images Section with beautiful grid
                    if (day.images.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(w * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(w * 0.02),
                            ),
                            child: Icon(Icons.photo_library, color: Colors.orange[700], size: w * 0.055),
                          ),
                          SizedBox(width: w * 0.025),
                          Text(
                            'Session Images',
                            style: TextStyle(
                              fontSize: w * 0.048,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.005),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(w * 0.03),
                            ),
                            child: Text(
                              '${day.images.length}',
                              style: TextStyle(
                                fontSize: w * 0.036,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.015),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: w * 0.03,
                          mainAxisSpacing: h * 0.015,
                          childAspectRatio: 1,
                        ),
                        itemCount: day.images.length,
                        itemBuilder: (_, i) {
                          return GestureDetector(
                            onTap: () {
                              Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.black87,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: InteractiveViewer(
                                          child: Image.network(day.images[i].imageUrl, fit: BoxFit.contain),
                                        ),
                                      ),
                                      Positioned(
                                        top: h * 0.02,
                                        right: w * 0.02,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(w * 0.06),
                                          ),
                                          child: IconButton(
                                            onPressed: () => Get.back(),
                                            icon: Icon(Icons.close, color: Colors.white, size: w * 0.07),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'day_image_${day.dayNumber}_$i',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(w * 0.035),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(w * 0.035),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(day.images[i].imageUrl, fit: BoxFit.cover),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: w * 0.02,
                                        right: w * 0.02,
                                        child: Container(
                                          padding: EdgeInsets.all(w * 0.015),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(w * 0.015),
                                          ),
                                          child: Icon(Icons.fullscreen, color: Colors.white, size: w * 0.04),
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParametersList(Map<String, dynamic> params, double w, double h) {
    List<Widget> widgets = [];

    // Parse and organize parameters beautifully
    params.forEach((key, value) {
      if (value is Map) {
        // Nested parameters (like dialysis, voluntary)
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.006),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.15), Colors.blue.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(w * 0.015),
                ),
                child: Text(
                  _formatParameterKey(key),
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(height: h * 0.01),
              ...((value as Map).entries.map((e) => _buildParameterRow(e.key, e.value, w, h, isNested: true)).toList()),
              SizedBox(height: h * 0.015),
            ],
          ),
        );
      } else {
        widgets.add(_buildParameterRow(key, value, w, h));
      }
    });

    return widgets;
  }

  Widget _buildParameterRow(String key, dynamic value, double w, double h, {bool isNested = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isNested ? w * 0.03 : 0,
        bottom: h * 0.008,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: h * 0.004),
            width: w * 0.015,
            height: w * 0.015,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: w * 0.037, color: Colors.grey[800], height: 1.4),
                children: [
                  TextSpan(
                    text: '${_formatParameterKey(key)}: ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  TextSpan(
                    text: _formatParameterValue(value),
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatParameterKey(String key) {
    // Convert camelCase to readable format
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatParameterValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is num) return value.toString();
    return value.toString();
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}