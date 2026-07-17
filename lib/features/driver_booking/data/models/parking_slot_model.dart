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
    // Handle zone: can be a Map (populated), a String (ID only), or null
    String? zoneId;
    String? zoneName;
    if (json['zone'] is Map) {
      zoneId = json['zone']['_id'];
      zoneName = json['zone']['name'];
    } else if (json['zone'] is String) {
      zoneId = json['zone'];
    }
    zoneName ??= json['zoneName'] ?? json['zone_name'];

    // Handle floor: can be a Map (populated), a String (ID only), or null
    String? floorId;
    String? floorName;
    if (json['floor'] is Map) {
      floorId = json['floor']['_id'];
      floorName = json['floor']['name'] ?? json['floor']['floorNumber']?.toString();
    } else if (json['floor'] is String) {
      floorId = json['floor'];
    }
    floorName ??= json['floorName'] ?? json['floor_name'];

    return ParkingSlotModel(
      id: json['_id'] ?? '',
      slotCode: json['slotCode'] ?? '',
      zoneId: zoneId,
      zoneName: zoneName,
      floorId: floorId,
      floorName: floorName,
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
