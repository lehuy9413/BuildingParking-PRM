import 'package:equatable/equatable.dart';
import 'parking_slot.dart';

enum BookingStatus { pending, confirmed, active, completed, cancelled }

class Booking extends Equatable {
  final String id;
  final String slotId;
  final String slotNumber;
  final ParkingZone zone;
  final VehicleType vehicleType;
  final String? licensePlate;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final double totalPrice;
  final BookingStatus status;
  final String qrCode;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.slotId,
    required this.slotNumber,
    required this.zone,
    required this.vehicleType,
    this.licensePlate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalPrice,
    required this.status,
    required this.qrCode,
    required this.createdAt,
  });

  Duration get duration => checkOutTime.difference(checkInTime);

  String get zoneName {
    switch (zone) {
      case ParkingZone.zoneA:
        return 'Zone A - Ground Floor';
      case ParkingZone.zoneB:
        return 'Zone B - Level 1';
      case ParkingZone.zoneC:
        return 'Zone C - Level 2';
      case ParkingZone.zoneD:
        return 'Zone D - Rooftop';
    }
  }

  String get vehicleTypeName {
    switch (vehicleType) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorbike:
        return 'Motorbike';
      case VehicleType.ev:
        return 'Electric Vehicle';
    }
  }

  @override
  List<Object?> get props => [
        id, slotId, slotNumber, zone, vehicleType, licensePlate,
        checkInTime, checkOutTime, totalPrice, status, qrCode, createdAt,
      ];
}
