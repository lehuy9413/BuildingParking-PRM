import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;
  CreateBooking(this.repository);

  Future<Booking> call({
    required String parkingLotId,
    required String vehicleTypeId,
    required DateTime scheduledDate,
    required String startTime,
    required String endTime,
    String? vehicleId,
    String? floorId,
    String? zoneId,
  }) {
    return repository.createBooking(
      parkingLotId: parkingLotId,
      vehicleTypeId: vehicleTypeId,
      scheduledDate: scheduledDate,
      startTime: startTime,
      endTime: endTime,
      vehicleId: vehicleId,
      floorId: floorId,
      zoneId: zoneId,
    );
  }
}
