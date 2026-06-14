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

  const ParkingSession({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.entryGate,
    required this.suggestedArea,
    required this.checkInTime,
    this.checkOutTime,
    this.isPaid = false,
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
    );
  }

  /// Tính phí đỗ xe theo loại xe (VND/giờ), tối thiểu 1 giờ.
  double calculateFee({DateTime? until}) {
    final end = until ?? checkOutTime ?? DateTime.now();
    final durationMinutes = end.difference(checkInTime).inMinutes;
    final hoursRaw = (durationMinutes / 60).ceil();
    final hours = hoursRaw < 1 ? 1 : hoursRaw;
    final ratePerHour = switch (vehicleType) {
      'Motorbike' => 5000.0,
      'Car' => 15000.0,
      'EV' => 20000.0,
      _ => 5000.0,
    };
    return hours * ratePerHour;
  }

  /// Gợi ý khu vực theo loại xe.
  static String suggestedAreaFor(String vehicleType) {
    return switch (vehicleType) {
      'Motorbike' => 'B1 - Zone M',
      'Car' => 'Floor 2 - Zone C',
      'EV' => 'Floor 1 - EV Charging Zone',
      _ => 'B1 - Zone M',
    };
  }

  bool get isActive => !isPaid && checkOutTime == null;
}
