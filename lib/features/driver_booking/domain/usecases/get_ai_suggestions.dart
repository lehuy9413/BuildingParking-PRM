import '../entities/ai_suggestion.dart';
import '../repositories/booking_repository.dart';

class GetAiSuggestions {
  final BookingRepository repository;
  GetAiSuggestions(this.repository);

  Future<List<AiSuggestion>> call({
    required String parkingLotId,
    required String vehicleTypeId,
  }) {
    return repository.getAiSuggestions(
      parkingLotId: parkingLotId,
      vehicleTypeId: vehicleTypeId,
    );
  }
}
