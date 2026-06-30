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
    );
  }
}
