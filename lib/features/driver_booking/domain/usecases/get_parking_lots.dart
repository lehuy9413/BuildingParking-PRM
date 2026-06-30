import '../entities/parking_lot.dart';
import '../repositories/booking_repository.dart';

class GetParkingLots {
  final BookingRepository repository;
  GetParkingLots(this.repository);

  Future<List<ParkingLot>> call() {
    return repository.getParkingLots();
  }
}
