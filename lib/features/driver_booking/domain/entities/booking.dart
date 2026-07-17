import 'package:equatable/equatable.dart';

enum BookingStatus { pending, approved, rejected, cancelled, completed, noShow }

class Booking extends Equatable {
  final String id;
  final String bookingCode;
  final String parkingLotId;
  final String parkingLotName;
  final String? slotId;
  final String? slotCode;
  final String? floorName;
  final String? zoneName;
  final String vehicleTypeName;
  final String licensePlate;
  final DateTime scheduledDate;
  final String startTime;
  final String endTime;
  final double estimatedFee;
  final double? actualFee;
  final double? overtimeFee;
  final BookingStatus status;
  final String? qrCode;

  const Booking({
    required this.id,
    required this.bookingCode,
    required this.parkingLotId,
    required this.parkingLotName,
    this.slotId,
    this.slotCode,
    this.floorName,
    this.zoneName,
    required this.vehicleTypeName,
    required this.licensePlate,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.estimatedFee,
    this.actualFee,
    this.overtimeFee,
    required this.status,
    this.qrCode,
  });

  @override
  List<Object?> get props => [
        id, bookingCode, parkingLotId, parkingLotName, slotId, slotCode, floorName, zoneName,
        vehicleTypeName, licensePlate, scheduledDate, startTime, endTime, estimatedFee, actualFee, overtimeFee, status, qrCode,
      ];
}
