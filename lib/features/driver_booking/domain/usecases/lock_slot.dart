import '../repositories/booking_repository.dart';

class LockSlot {
  final BookingRepository repository;
  LockSlot(this.repository);

  Future<bool> call(String slotId) {
    return repository.lockSlot(slotId);
  }
}
