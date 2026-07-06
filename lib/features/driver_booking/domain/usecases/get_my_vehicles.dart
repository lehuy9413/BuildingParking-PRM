import '../entities/vehicle.dart';
import '../repositories/booking_repository.dart';

class GetMyVehicles {
  final BookingRepository repository;
  GetMyVehicles(this.repository);

  Future<List<Vehicle>> call() {
    return repository.getMyVehicles();
  }
}
