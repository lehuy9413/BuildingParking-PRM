/// Model đại diện cho một phiên đỗ xe (ánh xạ từ JSON backend).
class ParkingSessionApiModel {
  final String id;
  final String sessionCode;
  final String licensePlate;
  final String vehicleTypeName;
  final String vehicleTypeId;
  final String slotCode;
  final String floorName;
  final String? zoneName;
  final String parkingLotId;
  final String? bookingId; // null = walk-in session
  final DateTime entryTime;
  final DateTime? exitTime;
  final double totalFee;
  final double baseFee;
  final double overtimeFee;
  final bool isOvertime;
  final String status; // 'active' | 'completed' | 'cancelled'
  final String paymentStatus; // 'unpaid' | 'paid'
  final String? paymentId;

  const ParkingSessionApiModel({
    required this.id,
    required this.sessionCode,
    required this.licensePlate,
    required this.vehicleTypeName,
    required this.vehicleTypeId,
    required this.slotCode,
    required this.floorName,
    this.zoneName,
    required this.parkingLotId,
    this.bookingId,
    required this.entryTime,
    this.exitTime,
    this.totalFee = 0,
    this.baseFee = 0,
    this.overtimeFee = 0,
    this.isOvertime = false,
    this.status = 'active',
    this.paymentStatus = 'unpaid',
    this.paymentId,
  });

  factory ParkingSessionApiModel.fromJson(Map<String, dynamic> json) {
    final vehicleType = json['vehicleType'];
    final slot = json['slot'];
    final floor = json['floor'];
    final zone = json['zone'];
    final vehicleInfo = json['vehicleInfo'] ?? {};

    return ParkingSessionApiModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      sessionCode: json['sessionCode']?.toString() ?? '',
      licensePlate: vehicleInfo['licensePlate']?.toString() ?? '',
      vehicleTypeName: vehicleType is Map
          ? vehicleType['name']?.toString() ?? ''
          : vehicleType?.toString() ?? '',
      vehicleTypeId: vehicleType is Map
          ? vehicleType['_id']?.toString() ?? ''
          : vehicleType?.toString() ?? '',
      slotCode: slot is Map
          ? slot['slotCode']?.toString() ?? ''
          : slot?.toString() ?? '',
      floorName: floor is Map
          ? floor['name']?.toString() ?? 'Floor ${floor['floorNumber']}'
          : floor?.toString() ?? '',
      zoneName: zone is Map ? zone['name']?.toString() : null,
      parkingLotId: json['parkingLot'] is Map
          ? json['parkingLot']['_id']?.toString() ?? ''
          : json['parkingLot']?.toString() ?? '',
      bookingId: json['booking'] is Map
          ? json['booking']['_id']?.toString()
          : json['booking']?.toString(),
      entryTime: _parseDate(json['entryTime']),
      exitTime: json['exitTime'] != null ? _parseDate(json['exitTime']) : null,
      totalFee: (json['totalFee'] ?? 0).toDouble(),
      baseFee: (json['baseFee'] ?? 0).toDouble(),
      overtimeFee: (json['overtimeFee'] ?? 0).toDouble(),
      isOvertime: json['isOvertime'] ?? false,
      status: json['status']?.toString() ?? 'active',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      paymentId: json['payment']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val.toLocal();
    return (DateTime.tryParse(val.toString()) ?? DateTime.now()).toLocal();
  }

  /// Khu vực gợi ý hiển thị (floor + zone)
  String get suggestedArea {
    if (zoneName != null && zoneName!.isNotEmpty) {
      return '$floorName – $zoneName (Slot: $slotCode)';
    }
    return '$floorName (Slot: $slotCode)';
  }

  bool get isActive => status == 'active';
  bool get isPaid => paymentStatus == 'paid';
}
