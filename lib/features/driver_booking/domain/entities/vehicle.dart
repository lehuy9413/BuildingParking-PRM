import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String vehicleTypeId;
  final String vehicleTypeName;
  final String licensePlate;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehicleBrand;
  final String? nickname;
  final bool isDefault;

  const Vehicle({
    required this.id,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.licensePlate,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleBrand,
    this.nickname,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleTypeId,
        vehicleTypeName,
        licensePlate,
        vehicleModel,
        vehicleColor,
        vehicleBrand,
        nickname,
        isDefault,
      ];
}
