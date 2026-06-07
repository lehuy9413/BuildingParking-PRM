import '../entities/booking.dart';
import '../entities/parking_slot.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;
  CreateBooking(this.repository);

  Future<Booking> call({
    required String slotId,
    required VehicleType vehicleType,
    required String? licensePlate,
    required DateTime checkInTime,
    required DateTime checkOutTime,
  }) {
    return repository.createBooking(
      slotId: slotId, vehicleType: vehicleType, licensePlate: licensePlate,
      checkInTime: checkInTime, checkOutTime: checkOutTime,
    );
  }
}
