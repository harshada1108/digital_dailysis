// lib/pages/doctor/day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';
import 'package:intl/intl.dart';

class DayDetailPage extends StatelessWidget {
  final DayItem day;
  final String sessionStatus;

  const DayDetailPage({
    Key? key,
    required this.day,
    required this.sessionStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    Color statusColor = _getStatusColor(day.status);
    IconData statusIcon = _getStatusIcon(day.status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Beautiful gradient app bar
          SliverAppBar(
            expandedHeight: h * 0.22,
            floating: false,
            pinned: true,
            backgroundColor: statusColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [statusColor.withOpacity(0.85), statusColor],
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
                              width: w * 0.16,
                              height: w * 0.16,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(w * 0.04),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.dayNumber}',
                                    style: TextStyle(
                                      fontSize: w * 0.07,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'DAY',
                                    style: TextStyle(
                                      fontSize: w * 0.028,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.95),
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
                                    _getReadableDate(),
                                    style: TextStyle(
                                      fontSize: w * 0.048,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.006),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.006),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(w * 0.03),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, color: Colors.white, size: w * 0.04),
                                        SizedBox(width: w * 0.015),
                                        Text(
                                          day.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
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
              padding: EdgeInsets.all(w * 0.045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion Info
                  if (day.completedAt != null) ...[
                    _buildCompletionCard(w, h),
                    SizedBox(height: h * 0.025),
                  ],

                  // Treatment Parameters
                  if (day.parameters != null && day.parameters!.isNotEmpty) ...[
                    _buildSectionHeader('Treatment Details', Icons.analytics, Colors.blue, w, h),
                    SizedBox(height: h * 0.015),
                    _buildParametersCard(w, h),
                    SizedBox(height: h * 0.025),
                  ],

                  // Images Section
                  if (day.images.isNotEmpty) ...[
                    _buildSectionHeader('Session Photos', Icons.photo_library, Colors.orange, w, h),
                    SizedBox(height: h * 0.015),
                    _buildImagesGrid(w, h),
                    SizedBox(height: h * 0.025),
                  ],

                  // No data message
                  if (day.completedAt == null &&
                      (day.parameters == null || day.parameters!.isEmpty) &&
                      day.images.isEmpty) ...[
                    _buildEmptyState(w, h),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.12), Colors.green.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.03),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(w * 0.03),
            ),
            child: Icon(Icons.check_circle_outline, color: Colors.green[700], size: w * 0.08),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Treatment Completed',
                  style: TextStyle(
                    fontSize: w * 0.038,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: h * 0.006),
                Text(
                  _formatDateTime(day.completedAt!),
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
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
          padding: EdgeInsets.all(w * 0.025),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(w * 0.025),
          ),
          child: Icon(icon, color: color, size: w * 0.06),
        ),
        SizedBox(width: w * 0.03),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildParametersCard(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.blue.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildParametersList(day.parameters!, w, h),
      ),
    );
  }

  List<Widget> _buildParametersList(Map<String, dynamic> params, double w, double h) {
    List<Widget> widgets = [];

    params.forEach((key, value) {
      if (value is Map) {
        // Category header for nested parameters
        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: h * 0.012, top: widgets.isEmpty ? 0 : h * 0.015),
            padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.008),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.15), Colors.blue.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(w * 0.02),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, color: Colors.blue[700], size: w * 0.045),
                SizedBox(width: w * 0.02),
                Text(
                  _formatParameterKey(key),
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        );

        // Add nested parameters
        (value as Map).forEach((nestedKey, nestedValue) {
          widgets.add(_buildParameterRow(nestedKey, nestedValue, w, h, isNested: true));
        });
      } else {
        widgets.add(_buildParameterRow(key, value, w, h));
      }
    });

    return widgets;
  }

  Widget _buildParameterRow(String key, dynamic value, double w, double h, {bool isNested = false}) {
    return Container(
      margin: EdgeInsets.only(
        left: isNested ? w * 0.04 : 0,
        bottom: h * 0.012,
      ),
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(w * 0.025),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: h * 0.003),
            width: w * 0.02,
            height: w * 0.02,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatParameterKey(key),
                  style: TextStyle(
                    fontSize: w * 0.036,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: h * 0.004),
                Text(
                  _formatParameterValue(value),
                  style: TextStyle(
                    fontSize: w * 0.042,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid(double w, double h) {
    return GridView.builder(
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
          onTap: () => _showImageDialog(day.images[i].imageUrl, w, h),
          child: Hero(
            tag: 'day_${day.dayNumber}_image_$i',
            child: Container(
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(day.images[i].imageUrl, fit: BoxFit.cover),
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
                      bottom: w * 0.025,
                      right: w * 0.025,
                      child: Container(
                        padding: EdgeInsets.all(w * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(w * 0.02),
                        ),
                        child: Icon(Icons.zoom_in, color: Colors.white, size: w * 0.045),
                      ),
                    ),
                    Positioned(
                      top: w * 0.025,
                      left: w * 0.025,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.005),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(w * 0.02),
                        ),
                        child: Text(
                          '${i + 1}/${day.images.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.032,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog(String imageUrl, double w, double h) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: h * 0.02,
              right: w * 0.02,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
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
  }

  Widget _buildEmptyState(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: w * 0.2, color: Colors.grey[400]),
          SizedBox(height: h * 0.02),
          Text(
            'No Details Available',
            style: TextStyle(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: h * 0.01),
          Text(
            'Treatment details will appear here once the session is completed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: w * 0.038,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getReadableDate() {
    if (day.completedAt != null) {
      return DateFormat('EEEE, MMMM d').format(day.completedAt!.toLocal());
    }
    return 'Day ${day.dayNumber}';
  }

  String _formatParameterKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatParameterValue(dynamic value) {
    if (value == null) return 'Not Available';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is num) return value.toString();
    return value.toString();
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('EEEE, MMM d, yyyy • h:mm a').format(local);
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