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
class MaterialSessionResponse {
  final bool success;
  final MaterialSession materialSession;


  MaterialSessionResponse({
    required this.success,
    required this.materialSession,

  });

  factory MaterialSessionResponse.fromJson(Map<String, dynamic> body) {
    final json = Map<String, dynamic>.from(body);

    return MaterialSessionResponse(

      success: json['success'] ?? false,
      materialSession:
      MaterialSession.fromJson(json['materialSession'] ?? {}),

    );
  }
}


class MaterialSession {
  final String materialSessionId;
  final DateTime? createdAt;
  final String status;
  final DateTime? acknowledgedAt;
  final Materials materials;
  final int totalSessionsAllowed;
  final int completedSessions;
  final int remainingSessions;
  final List<MaterialImage> materialImages;
  final List<DialysisSession> dialysisSessions;

  MaterialSession({
    required this.materialSessionId,
    required this.createdAt,
    required this.status,
    required this.acknowledgedAt,
    required this.materials,
    required this.totalSessionsAllowed,
    required this.completedSessions,
    required this.remainingSessions,
    required this.materialImages,
    required this.dialysisSessions,
  });

  factory MaterialSession.fromJson(Map<String, dynamic> j) {
    print("printing dailysis sessions");
    print(j['dialysisSessions']);
    return MaterialSession(

      materialSessionId: j['materialSessionId'] ?? '',
      createdAt:
      j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
      status: j['status'] ?? '',
      acknowledgedAt: j['acknowledgedAt'] != null
          ? DateTime.parse(j['acknowledgedAt'])
          : null,
      materials: Materials.fromJson(j['materials'] ?? {}),
      totalSessionsAllowed: j['totalSessionsAllowed'] ?? 0,
      completedSessions: j['completedSessions'] ?? 0,
      remainingSessions: j['remainingSessions'] ?? 0,
      materialImages: (j['materialImages'] as List<dynamic>?)
          ?.map((e) => MaterialImage.fromJson(e))
          .toList() ??
          [],
      dialysisSessions: (j['dialysisSessions'] as List<dynamic>?)
          ?.map((e) => DialysisSession.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList() ??
          [],
    );
  }
}
class Materials {
  final PDMaterals? pdMaterials;
  final int sessionsCount;


  Materials({
    required this.pdMaterials,
    required this.sessionsCount,

  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
      pdMaterials: json['pdMaterials'] != null
          ? PDMaterals.fromJson(json['pdMaterials'])
          : null,
      sessionsCount: json['sessionsCount'] ?? 0,

    );
  }
}
class PDMaterals {
  final Map<String, dynamic>? capd;
  final Map<String, dynamic>? apd;
  final Map<String, dynamic>? others;
  final int transferSet;
  final int icodextrin2L;
  final int minicap;


  PDMaterals({
    this.capd,
    this.apd,
    this.others,
    required this.transferSet,
    required this.icodextrin2L,
    required this.minicap,

  });

  factory PDMaterals.fromJson(Map<String, dynamic> json) {
    return PDMaterals(
      capd: json['capd'] as Map<String, dynamic>?,
      apd: json['apd'] as Map<String, dynamic>?,
      others: json['others'] as Map<String, dynamic>?,
      transferSet: json['transferSet'] ?? 0,
      icodextrin2L: json['icodextrin2L'] ?? 0,
      minicap: json['minicap'] ?? 0,
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

class DialysisSession {
  final String sessionId;
  final String status;
  final DateTime? completedAt;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final String? verifiedBy;
  final SessionParameters? parameters;
  final Materials? materials;
  final List<MaterialImage> images;

  DialysisSession({
    required this.sessionId,
    required this.status,
    required this.completedAt,
    required this.verifiedAt,
    required this.verificationNotes,
    required this.verifiedBy,
    required this.parameters,
    required this.materials,
    required this.images,
  });

  factory DialysisSession.fromJson(Map<String, dynamic> j) {
    return DialysisSession(
      sessionId: j['sessionId'] ?? j['_id'] ?? '',
      status: j['status'] ?? '',
      completedAt: j['completedAt'] != null
          ? DateTime.parse(j['completedAt'])
          : null,
      verifiedAt: j['verifiedAt'] != null
          ? DateTime.parse(j['verifiedAt'])
          : null,
      verificationNotes: j['verificationNotes'],
      verifiedBy: j['verifiedBy'],
      parameters: j['parameters'] != null
          ? SessionParameters.fromJson(j['parameters'])
          : null,
      materials: j['materials'] != null
          ? Materials.fromJson(j['materials'])
          : null,
      images: (j['images'] as List<dynamic>?)
          ?.map((e) => MaterialImage.fromJson(e))
          .toList() ??
          [],
    );
  }
}


class SessionParameters {
  final VoluntaryParameters? voluntary;
  final DialysisReadings? readings;

  SessionParameters({this.voluntary, this.readings});

  factory SessionParameters.fromJson(Map<String, dynamic> j) {
    return SessionParameters(
      voluntary: j['voluntary'] != null
          ? VoluntaryParameters.fromJson(j['voluntary'])
          : null,
      readings: j['readings'] != null
          ? DialysisReadings.fromJson(j['readings'])
          : null,
    );
  }
}


class VoluntaryParameters {
  final int? wellbeing;

  final bool? appetite;
  final bool? nausea;
  final bool? vomiting;
  final bool? abdominalDiscomfort;
  final bool? constipation;
  final bool? diarrhea;

  final int? sleepQuality;
  final bool? fatigue;
  final bool? ableToDoActivities;

  final bool? breathlessness;
  final bool? footSwelling;
  final bool? facialPuffiness;
  final bool? rapidWeightGain;

  final bool? bpMeasured;
  final int? sbp;
  final int? dbp;

  final bool? weightMeasured;
  final double? weightKg;

  final bool? painDuringFillDrain;
  final bool? slowDrain;
  final bool? catheterLeak;
  final bool? exitSiteIssue;

  final String? effluentClarity;

  final bool? urinePassed;
  final String? urineAmount;
  final bool? fluidOverloadFeeling;

  final bool? fever;
  final bool? chills;
  final bool? newAbdominalPain;
  final bool? suddenUnwell;

  final String? comments;

  VoluntaryParameters({
    this.wellbeing,
    this.appetite,
    this.nausea,
    this.vomiting,
    this.abdominalDiscomfort,
    this.constipation,
    this.diarrhea,
    this.sleepQuality,
    this.fatigue,
    this.ableToDoActivities,
    this.breathlessness,
    this.footSwelling,
    this.facialPuffiness,
    this.rapidWeightGain,
    this.bpMeasured,
    this.sbp,
    this.dbp,
    this.weightMeasured,
    this.weightKg,
    this.painDuringFillDrain,
    this.slowDrain,
    this.catheterLeak,
    this.exitSiteIssue,
    this.effluentClarity,
    this.urinePassed,
    this.urineAmount,
    this.fluidOverloadFeeling,
    this.fever,
    this.chills,
    this.newAbdominalPain,
    this.suddenUnwell,
    this.comments,
  });

  factory VoluntaryParameters.fromJson(Map<String, dynamic> j) {
    return VoluntaryParameters(
      wellbeing: j['wellbeing'],
      appetite: j['appetite'],
      nausea: j['nausea'],
      vomiting: j['vomiting'],
      abdominalDiscomfort: j['abdominalDiscomfort'],
      constipation: j['constipation'],
      diarrhea: j['diarrhea'],
      sleepQuality: j['sleepQuality'],
      fatigue: j['fatigue'],
      ableToDoActivities: j['ableToDoActivities'],
      breathlessness: j['breathlessness'],
      footSwelling: j['footSwelling'],
      facialPuffiness: j['facialPuffiness'],
      rapidWeightGain: j['rapidWeightGain'],
      bpMeasured: j['bpMeasured'],
      sbp: j['sbp'],
      dbp: j['dbp'],
      weightMeasured: j['weightMeasured'],
      weightKg: j['weightKg'],
      painDuringFillDrain: j['painDuringFillDrain'],
      slowDrain: j['slowDrain'],
      catheterLeak: j['catheterLeak'],
      exitSiteIssue: j['exitSiteIssue'],
      effluentClarity: j['effluentClarity'],
      urinePassed: j['urinePassed'],
      urineAmount: j['urineAmount'],
      fluidOverloadFeeling: j['fluidOverloadFeeling'],
      fever: j['fever'],
      chills: j['chills'],
      newAbdominalPain: j['newAbdominalPain'],
      suddenUnwell: j['suddenUnwell'],
      comments: j['comments'],
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

class DialysisReadings {
  final int? fillVolume;
  final int? drainVolume;
  final int? fillTime;
  final int? drainTime;

  DialysisReadings({
    this.fillVolume,
    this.drainVolume,
    this.fillTime,
    this.drainTime,
  });

  factory DialysisReadings.fromJson(Map<String, dynamic> j) {
    return DialysisReadings(
      fillVolume: j['fillVolume'],
      drainVolume: j['drainVolume'],
      fillTime: j['fillTime'],
      drainTime: j['drainTime'],
    );
  }
}

