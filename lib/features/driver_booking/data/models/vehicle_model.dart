import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.vehicleTypeId,
    required super.vehicleTypeName,
    required super.licensePlate,
    super.vehicleModel,
    super.vehicleColor,
    super.vehicleBrand,
    super.nickname,
    super.isDefault = false,
    super.hourlyRate = 0.0,
    super.dayBlockRate = 0.0,
    super.nightBlockRate = 0.0,
    super.dailyRate = 0.0,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'] ?? '',
      vehicleTypeId: json['vehicleType']?['_id'] ?? (json['vehicleType'] is String ? json['vehicleType'] : ''),
      vehicleTypeName: json['vehicleType']?['name'] ?? 'Unknown',
      licensePlate: json['licensePlate'] ?? '',
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      vehicleBrand: json['vehicleBrand'],
      nickname: json['nickname'],
      isDefault: json['isDefault'] ?? false,
      hourlyRate: (json['vehicleType']?['pricing']?['hourlyRate'] ?? 0).toDouble(),
      dayBlockRate: (json['vehicleType']?['pricing']?['dayBlockRate'] ?? 0).toDouble(),
      nightBlockRate: (json['vehicleType']?['pricing']?['nightBlockRate'] ?? 0).toDouble(),
      dailyRate: (json['vehicleType']?['pricing']?['dailyRate'] ?? 0).toDouble(),
    );
  }
}
