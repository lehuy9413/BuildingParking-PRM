import '../../domain/entities/parking_slot.dart';

class ParkingSlotModel extends ParkingSlot {
  const ParkingSlotModel({
    required super.id,
    required super.slotCode,
    super.zoneId,
    super.zoneName,
    super.floorId,
    super.floorName,
    required super.status,
    super.lockedUntil,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      id: json['_id'] ?? '',
      slotCode: json['slotCode'] ?? '',
      zoneId: json['zone']?['_id'] ?? (json['zone'] is String ? json['zone'] : null),
      zoneName: json['zone']?['name'],
      floorId: json['floor']?['_id'] ?? (json['floor'] is String ? json['floor'] : null),
      floorName: json['floor']?['name'] ?? json['floor']?['floorNumber']?.toString(),
      status: _parseStatus(json['status']),
      lockedUntil: json['lockedUntil'] != null ? DateTime.tryParse(json['lockedUntil']) : null,
    );
  }

  static SlotStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'occupied': return SlotStatus.occupied;
      case 'reserved': return SlotStatus.reserved;
      case 'maintenance': return SlotStatus.maintenance;
      case 'locked': return SlotStatus.locked;
      case 'available':
      default:
        return SlotStatus.available;
    }
  }
}
