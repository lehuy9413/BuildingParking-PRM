import 'package:equatable/equatable.dart';
import 'parking_slot.dart';

class AiSuggestion extends Equatable {
  final String id;
  final ParkingSlot recommendedSlot;
  final double confidenceScore;
  final String reason;
  final int estimatedWalkTimeMinutes;
  final double occupancyRate;
  final List<String> advantages;

  const AiSuggestion({
    required this.id,
    required this.recommendedSlot,
    required this.confidenceScore,
    required this.reason,
    required this.estimatedWalkTimeMinutes,
    required this.occupancyRate,
    required this.advantages,
  });

  @override
  List<Object?> get props => [
        id, recommendedSlot, confidenceScore, reason,
        estimatedWalkTimeMinutes, occupancyRate, advantages,
      ];
}
