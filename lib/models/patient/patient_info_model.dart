// lib/models/patient/patient_info_model.dart

class PatientInfoResponse {
  final bool success;
  final PatientShort patient;
  final List<MaterialSession> materialSessions;

  PatientInfoResponse({
    required this.success,
    required this.patient,
    required this.materialSessions,
  });

  factory PatientInfoResponse.fromJson(Map<String, dynamic> j) {
    return PatientInfoResponse(
      success: j['success'] == true,
      patient: PatientShort.fromJson(j['patient'] ?? {}),
      materialSessions: (j['materialSessions'] as List<dynamic>?)
          ?.map((e) => MaterialSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class PatientShort {
  final String id;
  final String name;
  final String email;

  PatientShort({required this.id, required this.name, required this.email});

  factory PatientShort.fromJson(Map<String, dynamic> j) {
    return PatientShort(
      id: j['id'] ?? j['_id'] ?? '',
      name: j['name'] ?? '',
      email: j['email'] ?? '',
    );
  }
}

class MaterialSession {
  final String materialSessionId;
  final DateTime? createdAt;
  final String status;
  final DateTime? acknowledgedAt;
  final Materials materials;
  final int plannedSessions;
  final List<MaterialImage> materialImages;
  final List<DayItem> days;

  MaterialSession({
    required this.materialSessionId,
    required this.createdAt,
    required this.status,
    required this.acknowledgedAt,
    required this.materials,
    required this.plannedSessions,
    required this.materialImages,
    required this.days,
  });

  factory MaterialSession.fromJson(Map<String, dynamic> j) {
    return MaterialSession(
      materialSessionId: j['materialSessionId'] ?? j['materialSessionId'] ?? '',
      createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
      status: j['status'] ?? '',
      acknowledgedAt: j['acknowledgedAt'] != null ? DateTime.parse(j['acknowledgedAt']) : null,
      materials: Materials.fromJson(j['materials'] ?? {}),
      plannedSessions: j['plannedSessions'] ?? 0,
      materialImages: (j['materialImages'] as List<dynamic>?)
          ?.map((e) => MaterialImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      days: (j['days'] as List<dynamic>?)
          ?.map((e) => DayItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class Materials {
  final int sessionsCount;
  final String dialysisMachine;
  final bool dialyzer;
  final bool bloodTubingSets;
  final bool dialysisNeedles;
  final bool dialysateConcentrates;
  final bool heparin;
  final bool salineSolution;

  Materials({
    required this.sessionsCount,
    required this.dialysisMachine,
    required this.dialyzer,
    required this.bloodTubingSets,
    required this.dialysisNeedles,
    required this.dialysateConcentrates,
    required this.heparin,
    required this.salineSolution,
  });

  factory Materials.fromJson(Map<String, dynamic> j) {
    return Materials(
      sessionsCount: j['sessionsCount'] ?? 0,
      dialysisMachine: j['dialysisMachine'] ?? '',
      dialyzer: j['dialyzer'] ?? false,
      bloodTubingSets: j['bloodTubingSets'] ?? false,
      dialysisNeedles: j['dialysisNeedles'] ?? false,
      dialysateConcentrates: j['dialysateConcentrates'] ?? false,
      heparin: j['heparin'] ?? false,
      salineSolution: j['salineSolution'] ?? false,
    );
  }
}

class MaterialImage {
  final String id;
  final String imageUrl;
  final DateTime? uploadedAt;
  final String publicId;

  MaterialImage({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
    required this.publicId,
  });

  factory MaterialImage.fromJson(Map<String, dynamic> j) {
    return MaterialImage(
      id: j['id'] ?? j['_id'] ?? '',
      imageUrl: j['imageUrl'] ?? '',
      uploadedAt: j['uploadedAt'] != null ? DateTime.parse(j['uploadedAt']) : null,
      publicId: j['publicId'] ?? '',
    );
  }
}

class DayItem {
  final int dayNumber;
  final String status;
  final String? sessionId;
  final DateTime? completedAt;
  final Map<String, dynamic>? parameters;
  final List<MaterialImage> images;

  DayItem({
    required this.dayNumber,
    required this.status,
    required this.sessionId,
    required this.completedAt,
    required this.parameters,
    required this.images,
  });

  factory DayItem.fromJson(Map<String, dynamic> j) {
    return DayItem(
      dayNumber: j['dayNumber'] ?? 0,
      status: j['status'] ?? '',
      sessionId: j['sessionId'],
      completedAt: j['completedAt'] != null ? DateTime.parse(j['completedAt']) : null,
      parameters: j['parameters'] is Map ? Map<String, dynamic>.from(j['parameters']) : null,
      images: (j['images'] as List<dynamic>?)
          ?.map((e) => MaterialImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
