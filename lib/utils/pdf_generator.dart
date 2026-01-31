// lib/utils/pdf_generator.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;

class MaterialSessionPdfGenerator {
  static Future<void> generateMaterialSessionReport({
    required dynamic materialSession,
    required String patientName,
  }) async {
    final pdf = pw.Document();

    // Create the PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(materialSession, patientName),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Session Overview
            _buildSectionTitle('Session Overview'),
            pw.SizedBox(height: 10),
            _buildSessionOverview(materialSession),
            pw.SizedBox(height: 20),

            // Progress
            _buildSectionTitle('Session Progress'),
            pw.SizedBox(height: 10),
            _buildProgressSection(materialSession),
            pw.SizedBox(height: 20),

            // PD Materials
            _buildSectionTitle('PD Materials Supply'),
            pw.SizedBox(height: 10),
            _buildPDMaterialsSection(materialSession),
            pw.SizedBox(height: 20),

            // Dialysis Sessions
            if (materialSession.dialysisSessions != null &&
                materialSession.dialysisSessions.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSectionTitle('Dialysis Sessions Detail'),
              pw.SizedBox(height: 10),
              ...materialSession.dialysisSessions.asMap().entries.map(
                    (entry) => _buildDialysisSessionDetail(
                  entry.value,
                  entry.key + 1,
                ),
              ),
            ],

            // Footer
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    // Save and open the PDF
    await _savePdf(pdf, patientName);
  }


  static pw.Widget _buildHeader(dynamic materialSession, String patientName) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PD Material Session Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Patient: $patientName',
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: _getStatusPdfColor(materialSession.status),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  materialSession.status.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue200, width: 2),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  static pw.Widget _buildSessionOverview(dynamic materialSession) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('Session ID', materialSession.materialSessionId ?? 'N/A'),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'Created At',
            _formatDate(materialSession.createdAt),
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow(
            'Total Sessions Allowed',
            '${materialSession.totalSessionsAllowed ?? 0}',
          ),
          if (materialSession.acknowledgedAt != null) ...[
            pw.SizedBox(height: 8),
            _buildInfoRow(
              'Acknowledged At',
              _formatDate(materialSession.acknowledgedAt),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildProgressSection(dynamic materialSession) {
    final total = materialSession.totalSessionsAllowed ?? 0;
    final completed = materialSession.completedSessions ?? 0;
    final remaining = materialSession.remainingSessions ?? 0;
    final progress = total > 0 ? completed / total : 0.0;

    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.blue50,
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Progress',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          // Progress bar
          pw.Container(
            height: 10,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(5),
              color: PdfColors.grey300,
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: (480*progress).toDouble(), // Adjust based on container width
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(5),
                    color: PdfColors.blue700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat('Total', total, PdfColors.blue),
              _buildProgressStat('Completed', completed, PdfColors.green),
              _buildProgressStat('Remaining', remaining, PdfColors.orange),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProgressStat(String label, int value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          '$value',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.Text(label, style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildPDMaterialsSection(dynamic materialSession) {
    final materials = materialSession.materials;
    if (materials == null) {
      return pw.Text('No materials data available');
    }

    final pdMaterials = materials.pdMaterials;
    if (pdMaterials == null) {
      return pw.Text('No PD materials data available');
    }

    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.green50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Transfer Set
          if (pdMaterials.transferSet != null && pdMaterials.transferSet > 0) ...[
            _buildMaterialItem('Transfer Set', '${pdMaterials.transferSet} units'),
            pw.SizedBox(height: 8),
          ],

          // CAPD Fluids
          if (_hasCapdFluids(pdMaterials.capd)) ...[
            pw.Text(
              'CAPD Fluids',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
                fontSize: 11,
              ),
            ),
            pw.SizedBox(height: 4),
            ..._buildCapdFluidsList(pdMaterials.capd),
            pw.SizedBox(height: 8),
          ],

          // APD Fluids
          if (_hasApdFluids(pdMaterials.apd)) ...[
            pw.Text(
              'APD Fluids',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
                fontSize: 11,
              ),
            ),
            pw.SizedBox(height: 4),
            ..._buildApdFluidsList(pdMaterials.apd),
            pw.SizedBox(height: 8),
          ],

          // Icodextrin
          if (pdMaterials.icodextrin2L != null && pdMaterials.icodextrin2L > 0) ...[
            _buildMaterialItem('Icodextrin 2L', '${pdMaterials.icodextrin2L} units'),
            pw.SizedBox(height: 8),
          ],

          // Minicap
          if (pdMaterials.minicap != null && pdMaterials.minicap > 0) ...[
            _buildMaterialItem('Minicap', '${pdMaterials.minicap} units'),
            pw.SizedBox(height: 8),
          ],

          // Others
          if (pdMaterials.others != null &&
              pdMaterials.others['quantity'] != null &&
              pdMaterials.others['quantity'] > 0) ...[
            _buildMaterialItem(
              'Other Materials',
              '${pdMaterials.others['quantity']} units',
            ),
            if (pdMaterials.others['description'] != null &&
                pdMaterials.others['description'].isNotEmpty)
              pw.Padding(
                padding: pw.EdgeInsets.only(left: 16, top: 2),
                child: pw.Text(
                  'Description: ${pdMaterials.others['description']}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
          ],
        ],
      ),
    );
  }

  static bool _hasCapdFluids(dynamic capd) {
    if (capd == null) return false;
    final fluids = capd as Map<String, dynamic>;
    return fluids.values.any((value) => value != null && value > 0);
  }

  static bool _hasApdFluids(dynamic apd) {
    if (apd == null) return false;
    final fluids = apd as Map<String, dynamic>;
    return fluids.values.any((value) => value != null && value > 0);
  }

  static List<pw.Widget> _buildCapdFluidsList(dynamic capd) {
    final fluids = capd as Map<String, dynamic>;
    final fluidsList = <pw.Widget>[];

    final fluidLabels = {
      'fluid1_5_2L': 'Fluid 1.5% 2L',
      'fluid2_5_2L': 'Fluid 2.5% 2L',
      'fluid4_25_2L': 'Fluid 4.25% 2L',
      'fluid1_5_1L': 'Fluid 1.5% 1L',
      'fluid2_5_1L': 'Fluid 2.5% 1L',
      'fluid4_25_1L': 'Fluid 4.25% 1L',
    };

    fluids.forEach((key, value) {
      if (value != null && value > 0) {
        fluidsList.add(
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: pw.Text(
              '- ${fluidLabels[key] ?? key}: $value bags',
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        );
      }
    });

    return fluidsList;
  }

  static List<pw.Widget> _buildApdFluidsList(dynamic apd) {
    final fluids = apd as Map<String, dynamic>;
    final fluidsList = <pw.Widget>[];

    final fluidLabels = {
      'fluid1_7_1L': 'Fluid 1.7% 1L',
    };

    fluids.forEach((key, value) {
      if (value != null && value > 0) {
        fluidsList.add(
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 16, top: 2, bottom: 2),
            child: pw.Text(
              '- ${fluidLabels[key] ?? key}: $value bags',
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
        );
      }
    });

    return fluidsList;
  }

  static pw.Widget _buildMaterialItem(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDialysisSessionDetail(
      dynamic session,
      int sessionNumber,
      ) {
    final status = session.status ?? 'unknown';
    final completedAt = session.completedAt;
    final parameters = session.parameters;
    final voluntary = parameters?.voluntary;

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 16),
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _getStatusPdfColor(status), width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
        color: _getStatusPdfColor(status).shade(0.95),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Session Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Session $sessionNumber',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _getStatusPdfColor(status),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  status.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),

          // Session Info
          _buildInfoRow('Session ID', session.sessionId ?? 'N/A'),
          if (completedAt != null) ...[
            pw.SizedBox(height: 4),
            _buildInfoRow('Completed At', _formatDate(completedAt)),
          ],

          // Parameters
          if (voluntary != null) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Patient Parameters',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo,
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 8),

            // Wellbeing & Vitals
            pw.Text(
              'Wellbeing & Vital Signs',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            _buildInfoRow('Wellbeing Score', '${voluntary.wellbeing}/10'),
            _buildInfoRow('Sleep Quality', '${voluntary.sleepQuality}/10'),
            if (voluntary.bpMeasured == true)
              _buildInfoRow('Blood Pressure', '${voluntary.sbp}/${voluntary.dbp} mmHg'),
            if (voluntary.weightMeasured == true)
              _buildInfoRow('Weight', '${voluntary.weightKg} kg'),

            pw.SizedBox(height: 8),

            // Symptoms Summary
            pw.Text(
              'Symptoms',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (voluntary.appetite == true)
                  pw.Text('- Appetite: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.nausea == true)
                  pw.Text('- Nausea: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.vomiting == true)
                  pw.Text('- Vomiting: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.fatigue == true)
                  pw.Text('- Fatigue: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.breathlessness == true)
                  pw.Text('- Breathlessness: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.footSwelling == true)
                  pw.Text('- Foot Swelling: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.fever == true)
                  pw.Text('- Fever: Yes', style: pw.TextStyle(fontSize: 9)),
                if (voluntary.chills == true)
                  pw.Text('- Chills: Yes', style: pw.TextStyle(fontSize: 9)),
              ],
            ),

            pw.SizedBox(height: 8),

            // Dialysis Details
            pw.Text(
              'Dialysis Details',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            _buildInfoRow(
              'Pain During Fill/Drain',
              voluntary.painDuringFillDrain == true ? 'Yes' : 'No',
            ),
            _buildInfoRow('Slow Drain', voluntary.slowDrain == true ? 'Yes' : 'No'),
            _buildInfoRow('Catheter Leak', voluntary.catheterLeak == true ? 'Yes' : 'No'),
            _buildInfoRow(
              'Effluent Clarity',
              voluntary.effluentClarity ?? 'N/A',
            ),

            // Comments
            if (voluntary.comments != null && voluntary.comments.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                'Comments',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple50,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  voluntary.comments,
                  style: pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9)),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.only(top: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This is a system-generated report',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Digital Dialysis - Material Session Report',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getStatusPdfColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return PdfColors.orange;
      case 'completed':
        return PdfColors.blue;
      case 'pending':
        return PdfColors.grey;
      case 'verified':
        return PdfColors.green;
      case 'cancelled':
        return PdfColors.red;
      case 'acknowledged':
        return PdfColors.teal;
      default:
        return PdfColors.grey;
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('d MMM yyyy, h:mm a').format(date.toLocal());
  }

  static Future<void> _savePdf(pw.Document pdf, String patientName) async {
    try {
      final bytes = await pdf.save();

      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'MaterialSession_${patientName.replaceAll(' ', '_')}_$timestamp.pdf';

      if (kIsWeb) {
        // WEB PLATFORM
        await _saveWebPdf(bytes, fileName);
      } else {
        // MOBILE PLATFORM
        await _saveMobilePdf(bytes, fileName);
      }
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }
  static Future<void> _saveWebPdf(List<int> bytes, String fileName) async {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = fileName
      ..click();
    html.Url.revokeObjectUrl(url);
    print('PDF downloaded for web: $fileName');
  }
  static Future<void> _saveMobilePdf(List<int> bytes, String fileName) async {
    Directory? directory;

    try {
      // For Android, save to Downloads folder
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } catch (e) {
      print('Error getting directory: $e');
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    print('PDF saved to: ${file.path}');

    try {
      await OpenFile.open(file.path);
    } catch (e) {
      print('Could not open PDF automatically: $e');
    }
}}