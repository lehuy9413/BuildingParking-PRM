import 'package:equatable/equatable.dart';

class VehicleType extends Equatable {
  final String id;
  final String name;
  final String code;
  final double hourlyRate;
  final double dayBlockRate;
  final double nightBlockRate;

  const VehicleType({
    required this.id,
    required this.name,
    required this.code,
    this.hourlyRate = 0.0,
    this.dayBlockRate = 0.0,
    this.nightBlockRate = 0.0,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};
    return VehicleType(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      hourlyRate: (pricing['hourlyRate'] ?? 0).toDouble(),
      dayBlockRate: (pricing['dayBlockRate'] ?? 0).toDouble(),
      nightBlockRate: (pricing['nightBlockRate'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, code, hourlyRate, dayBlockRate, nightBlockRate];
}
