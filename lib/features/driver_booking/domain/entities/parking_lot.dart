import 'package:equatable/equatable.dart';

class ParkingLot extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? address;
  
  const ParkingLot({
    required this.id,
    required this.name,
    required this.code,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, code, address];
}
