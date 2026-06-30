import '../../domain/entities/parking_lot.dart';

class ParkingLotModel extends ParkingLot {
  const ParkingLotModel({
    required super.id,
    required super.name,
    required super.code,
    super.address,
  });

  factory ParkingLotModel.fromJson(Map<String, dynamic> json) {
    String parsedAddress = '';
    if (json['address'] != null) {
      final addr = json['address'];
      parsedAddress = [addr['street'], addr['district'], addr['city']]
          .where((e) => e != null && e.toString().isNotEmpty)
          .join(', ');
    }

    return ParkingLotModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      address: parsedAddress.isEmpty ? null : parsedAddress,
    );
  }
}
