/// Model đại diện cho một phiên đỗ xe.
class ParkingSession {
  final String id;
  final String plateNumber;
  final String vehicleType; // 'Motorbike' | 'Car' | 'EV'
  final String entryGate; // 'Gate A' | 'Gate B' | 'Gate C'
  final String suggestedArea;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final bool isPaid;
  final bool hasBooking;
  final double totalFee;

  const ParkingSession({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.entryGate,
    required this.suggestedArea,
    required this.checkInTime,
    this.checkOutTime,
    this.isPaid = false,
    this.hasBooking = false,
    this.totalFee = 0.0,
  });

  ParkingSession copyWith({
    String? id,
    String? plateNumber,
    String? vehicleType,
    String? entryGate,
    String? suggestedArea,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isPaid,
    bool? hasBooking,
    double? totalFee,
  }) {
    return ParkingSession(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      entryGate: entryGate ?? this.entryGate,
      suggestedArea: suggestedArea ?? this.suggestedArea,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isPaid: isPaid ?? this.isPaid,
      hasBooking: hasBooking ?? this.hasBooking,
      totalFee: totalFee ?? this.totalFee,
    );
  }

  bool get isActive => !isPaid && checkOutTime == null;
}
