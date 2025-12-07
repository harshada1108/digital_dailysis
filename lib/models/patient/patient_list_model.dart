class PatientModel {
  final String id;
  final String name;
  final String email;

  PatientModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
