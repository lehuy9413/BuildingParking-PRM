/// Loại ngoại lệ cần xử lý
enum ExceptionType {
  lostCard,
  wrongVehicleInfo,
}

/// Model cho một yêu cầu xử lý ngoại lệ
class ExceptionRequest {
  final String id;
  final ExceptionType type;
  final String plateNumber;
  final String? notes;
  final DateTime createdAt;
  final String status; // 'pending' | 'resolved' | 'escalated'

  const ExceptionRequest({
    required this.id,
    required this.type,
    required this.plateNumber,
    this.notes,
    required this.createdAt,
    this.status = 'pending',
  });

  String get typeLabel => switch (type) {
        ExceptionType.lostCard => 'Mất thẻ xe',
        ExceptionType.wrongVehicleInfo => 'Sai thông tin xe',
      };
}

/// Trạng thái của một slot đỗ xe
enum SlotStatus { available, occupied, maintenance, locked }

/// Model cho một slot đỗ xe trong bãi
class ParkingSlot {
  final String id;
  final String label; // e.g. 'A01', 'B12'
  final String zone; // 'A' | 'B' | 'C'
  final int floor;
  final SlotStatus status;
  final String? occupiedBy; // biển số nếu đang có xe

  const ParkingSlot({
    required this.id,
    required this.label,
    required this.zone,
    required this.floor,
    required this.status,
    this.occupiedBy,
  });

  ParkingSlot copyWith({
    SlotStatus? status,
    String? occupiedBy,
  }) {
    return ParkingSlot(
      id: id,
      label: label,
      zone: zone,
      floor: floor,
      status: status ?? this.status,
      occupiedBy: occupiedBy ?? this.occupiedBy,
    );
  }
}

/// Model cho xe cảnh báo (quá hạn / sai khu vực)
enum VehicleAlertType { overdue, wrongZone }

class VehicleAlert {
  final String id;
  final String plateNumber;
  final String vehicleType;
  final String zone;
  final String slotLabel;
  final VehicleAlertType alertType;
  final DateTime checkInTime;
  final int? overdueHours; // nếu quá hạn
  final String? expectedZone; // nếu sai khu vực

  const VehicleAlert({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.zone,
    required this.slotLabel,
    required this.alertType,
    required this.checkInTime,
    this.overdueHours,
    this.expectedZone,
  });

  String get alertLabel => switch (alertType) {
        VehicleAlertType.overdue => 'Quá hạn gửi',
        VehicleAlertType.wrongZone => 'Sai khu vực',
      };
}
