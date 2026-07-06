import '../repositories/booking_repository.dart';

class UnlockSlot {
  final BookingRepository repository;
  UnlockSlot(this.repository);

  Future<bool> call(String slotId) {
    return repository.unlockSlot(slotId);
  }
}
