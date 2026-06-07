import '../entities/parking_slot.dart';
import '../repositories/booking_repository.dart';

class GetAvailableSlots {
  final BookingRepository repository;
  GetAvailableSlots(this.repository);

  Future<List<ParkingSlot>> call({
    required VehicleType vehicleType,
    required ParkingZone zone,
    required DateTime dateTime,
  }) {
    return repository.getAvailableSlots(
      vehicleType: vehicleType, zone: zone, dateTime: dateTime,
    );
  }
}
