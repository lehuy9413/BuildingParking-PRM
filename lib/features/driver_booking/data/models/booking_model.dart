import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.bookingCode,
    required super.parkingLotId,
    required super.parkingLotName,
    super.slotId,
    super.slotCode,
    super.floorName,
    super.zoneName,
    required super.vehicleTypeName,
    required super.licensePlate,
    required super.scheduledDate,
    required super.startTime,
    required super.endTime,
    required super.estimatedFee,
    super.actualFee,
    super.overtimeFee,
    required super.status,
    super.qrCode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle zone: can be a Map (populated), a String (ID), or null
    String? resolvedZoneName;
    if (json['zone'] is Map) {
      resolvedZoneName = json['zone']['name'];
    }
    // Fallbacks for zone name
    resolvedZoneName ??= json['zoneName'] ?? json['zone_name'];

    // Handle floor: can be a Map (populated), a String (ID), or null
    String? resolvedFloorName;
    if (json['floor'] is Map) {
      resolvedFloorName = json['floor']['name'] ?? json['floor']['floorNumber']?.toString();
    }
    resolvedFloorName ??= json['floorName'] ?? json['floor_name'];

    // Handle assignedSlot: can be a Map (populated) or a String (ID)
    String? resolvedSlotId;
    String? resolvedSlotCode;
    if (json['assignedSlot'] is Map) {
      resolvedSlotId = json['assignedSlot']['_id'];
      resolvedSlotCode = json['assignedSlot']['slotCode'];
      // If zone/floor still null, try to get from slot
      if (resolvedZoneName == null && json['assignedSlot']['zone'] is Map) {
        resolvedZoneName = json['assignedSlot']['zone']['name'];
      }
      if (resolvedFloorName == null && json['assignedSlot']['floor'] is Map) {
        resolvedFloorName = json['assignedSlot']['floor']['name'] ?? 
            json['assignedSlot']['floor']['floorNumber']?.toString();
      }
    } else if (json['assignedSlot'] is String) {
      resolvedSlotId = json['assignedSlot'];
    }
    resolvedSlotCode ??= json['slotCode'];

    return BookingModel(
      id: json['_id'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      parkingLotId: json['parkingLot'] is Map ? json['parkingLot']['_id'] ?? '' : (json['parkingLot'] is String ? json['parkingLot'] : ''),
      parkingLotName: json['parkingLot'] is Map ? json['parkingLot']['name'] ?? '' : '',
      slotId: resolvedSlotId,
      slotCode: resolvedSlotCode,
      floorName: resolvedFloorName,
      zoneName: resolvedZoneName,
      vehicleTypeName: json['vehicleType'] is Map ? json['vehicleType']['name'] ?? '' : '',
      licensePlate: json['vehicleInfo'] is Map ? json['vehicleInfo']['licensePlate'] ?? '' : '',
      scheduledDate: DateTime.parse(json['scheduledDate']).toLocal(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      estimatedFee: (json['estimatedFee'] ?? 0).toDouble(),
      actualFee: json['actualFee'] != null ? (json['actualFee'] as num).toDouble() : null,
      overtimeFee: json['overtimeFee'] != null ? (json['overtimeFee'] as num).toDouble() : null,
      status: _parseStatus(json['status']),
      qrCode: json['qrCode'],
    );
  }

  static BookingStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'approved': return BookingStatus.approved;
      case 'rejected': return BookingStatus.rejected;
      case 'cancelled': return BookingStatus.cancelled;
      case 'completed': return BookingStatus.completed;
      case 'no_show': return BookingStatus.noShow;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }
}

