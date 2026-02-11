class PatientProfileResponse {
  final bool success;
  final PatientProfile profile;

  PatientProfileResponse({
    required this.success,
    required this.profile,
  });

  factory PatientProfileResponse.fromJson(Map<String, dynamic> j) {
    return PatientProfileResponse(
      success: j['success'] ?? false,
      profile: PatientProfile.fromJson(j['profile'] ?? {}),
    );
  }
}

class PatientProfile {
  final String patientId;
  final String gender;
  final int age;
  final String bloodGroup;
  final String dialysisType;
  final String height;
  final String weight;
  final String primaryDiagnosis;
  final String nativeKidneyDisease;
  final List<String> allergies;
  final List<String> comorbidities;
  final String address;
  final String contactNumber;
  final String crNumber;
  final String educationLevel;
  final String incomeLevel;
  final EmergencyContact emergencyContact;

  PatientProfile({
    required this.patientId,
    required this.gender,
    required this.age,
    required this.bloodGroup,
    required this.dialysisType,
    required this.height,
    required this.weight,
    required this.primaryDiagnosis,
    required this.nativeKidneyDisease,
    required this.allergies,
    required this.comorbidities,
    required this.address,
    required this.contactNumber,
    required this.crNumber,
    required this.educationLevel,
    required this.incomeLevel,
    required this.emergencyContact,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> j) {
    return PatientProfile(
      patientId: j['patientId'] ?? '',
      gender: j['gender'] ?? '',
      age: j['age'] ?? 0,
      bloodGroup: j['bloodGroup'] ?? '',
      dialysisType: j['dialysisType'] ?? '',
      height: j['height'] ?? '',
      weight: j['weight'] ?? '',
      primaryDiagnosis: j['primaryDiagnosis'] ?? '',
      nativeKidneyDisease: j['nativeKidneyDisease'] ?? '',
      allergies: List<String>.from(j['allergies'] ?? []),
      comorbidities: List<String>.from(j['comorbidities'] ?? []),
      address: j['address'] ?? '',
      contactNumber: j['contactNumber'] ?? '',
      crNumber: j['crNumber'] ?? '',
      educationLevel: j['educationLevel'] ?? '',
      incomeLevel: j['incomeLevel'] ?? '',
      emergencyContact: EmergencyContact.fromJson(j['emergencyContact'] ?? {}),
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> j) {
    return EmergencyContact(
      name: j['name'] ?? '',
      phone: j['phone'] ?? '',
      relation: j['relation'] ?? '',
    );
  }
}
