import 'package:equatable/equatable.dart';

enum SlotStatus { available, occupied, reserved, maintenance }

enum VehicleType { car, motorbike, ev }

enum ParkingZone { zoneA, zoneB, zoneC, zoneD }

class ParkingSlot extends Equatable {
  final String id;
  final String slotNumber;
  final ParkingZone zone;
  final VehicleType vehicleType;
  final SlotStatus status;
  final String? floor;
  final double pricePerHour;

  const ParkingSlot({
    required this.id,
    required this.slotNumber,
    required this.zone,
    required this.vehicleType,
    required this.status,
    this.floor,
    required this.pricePerHour,
  });

  @override
  List<Object?> get props => [id, slotNumber, zone, vehicleType, status, floor, pricePerHour];
}
