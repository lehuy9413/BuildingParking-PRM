import 'package:equatable/equatable.dart';

enum SlotStatus { available, occupied, reserved, maintenance, locked }

class ParkingSlot extends Equatable {
  final String id;
  final String slotCode; 
  final String? zoneId;
  final String? zoneName;
  final String? floorId;
  final String? floorName;
  final SlotStatus status;
  final DateTime? lockedUntil;

  const ParkingSlot({
    required this.id,
    required this.slotCode,
    this.zoneId,
    this.zoneName,
    this.floorId,
    this.floorName,
    required this.status,
    this.lockedUntil,
  });

  @override
  List<Object?> get props => [
        id,
        slotCode,
        zoneId,
        zoneName,
        floorId,
        floorName,
        status,
        lockedUntil,
      ];
}
