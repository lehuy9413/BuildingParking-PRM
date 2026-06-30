import '../entities/parking_slot.dart';
import '../repositories/booking_repository.dart';

class GetAvailableSlots {
  final BookingRepository repository;
  GetAvailableSlots(this.repository);

  Future<List<ParkingSlot>> call({
    required String parkingLotId,
    required String vehicleTypeId,
    String? floorId,
    String? zoneId,
  }) {
    return repository.getAvailableSlots(
      parkingLotId: parkingLotId,
      vehicleTypeId: vehicleTypeId,
      floorId: floorId,
      zoneId: zoneId,
    );
  }
}
