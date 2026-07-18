class IncidentModel {
  final String id;
  final String? incidentCode;
  final String title;
  final String? description;
  final String? type;
  final String? status;
  final String? severity;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  IncidentModel({
    required this.id,
    this.incidentCode,
    required this.title,
    this.description,
    this.type,
    this.status,
    this.severity,
    this.createdAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      incidentCode: json['incidentCode']?.toString(),
      title: json['title'] ?? 'Unknown',
      description: json['description'],
      type: json['type'],
      status: json['status'],
      severity: json['severity'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      resolvedAt: (json['resolution'] != null && json['resolution']['resolvedAt'] != null)
          ? DateTime.tryParse(json['resolution']['resolvedAt'].toString())
          : (json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null),
      resolutionNote: json['resolution']?['description']?.toString(),
    );
  }
}
