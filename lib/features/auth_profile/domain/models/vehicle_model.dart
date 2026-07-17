class VehicleModel {
  final String id;
  final String licensePlate;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehicleBrand;
  final String? nickname;
  final bool isDefault;
  final dynamic vehicleType;

  VehicleModel({
    required this.id,
    required this.licensePlate,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleBrand,
    this.nickname,
    required this.isDefault,
    this.vehicleType,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      licensePlate: json['licensePlate'] ?? '',
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      vehicleBrand: json['vehicleBrand'],
      nickname: json['nickname'],
      isDefault: json['isDefault'] ?? false,
      vehicleType: json['vehicleType'],
    );
  }
}
