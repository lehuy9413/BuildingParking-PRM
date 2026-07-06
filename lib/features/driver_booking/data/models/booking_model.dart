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
    required super.status,
    super.qrCode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      parkingLotId: json['parkingLot'] is Map ? json['parkingLot']['_id'] ?? '' : (json['parkingLot'] is String ? json['parkingLot'] : ''),
      parkingLotName: json['parkingLot'] is Map ? json['parkingLot']['name'] ?? '' : '',
      slotId: json['assignedSlot'] is Map ? json['assignedSlot']['_id'] : (json['assignedSlot'] is String ? json['assignedSlot'] : null),
      slotCode: json['assignedSlot'] is Map ? json['assignedSlot']['slotCode'] : null,
      floorName: json['floor'] is Map ? json['floor']['name'] ?? json['floor']['floorNumber']?.toString() : null,
      zoneName: json['zone'] is Map ? json['zone']['name'] : null,
      vehicleTypeName: json['vehicleType'] is Map ? json['vehicleType']['name'] ?? '' : '',
      licensePlate: json['vehicleInfo'] is Map ? json['vehicleInfo']['licensePlate'] ?? '' : '',
      scheduledDate: DateTime.parse(json['scheduledDate']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      estimatedFee: (json['estimatedFee'] ?? 0).toDouble(),
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
