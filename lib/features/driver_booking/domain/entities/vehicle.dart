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
  final double hourlyRate;
  final double dayBlockRate;
  final double nightBlockRate;
  final double dailyRate;

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
    this.hourlyRate = 0.0,
    this.dayBlockRate = 0.0,
    this.nightBlockRate = 0.0,
    this.dailyRate = 0.0,
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
        hourlyRate,
        dayBlockRate,
        nightBlockRate,
        dailyRate,
      ];
}
