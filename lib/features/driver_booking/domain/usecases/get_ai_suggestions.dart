import '../entities/ai_suggestion.dart';
import '../entities/parking_slot.dart';
import '../repositories/booking_repository.dart';

class GetAiSuggestions {
  final BookingRepository repository;
  GetAiSuggestions(this.repository);

  Future<List<AiSuggestion>> call({
    required VehicleType vehicleType,
    required DateTime dateTime,
  }) {
    return repository.getAiSuggestions(
      vehicleType: vehicleType, dateTime: dateTime,
    );
  }
}
