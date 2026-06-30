import '../../domain/entities/booking.dart';
import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/parking_lot.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/api_booking_datasource.dart';
import '../models/parking_slot_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiBookingDataSource dataSource;
  BookingRepositoryImpl({required this.dataSource});

  @override
  Future<List<ParkingLot>> getParkingLots() => dataSource.getParkingLots();

  @override
  Future<List<Vehicle>> getMyVehicles() => dataSource.getMyVehicles();

  @override
  Future<List<ParkingSlot>> getAvailableSlots({
    required String parkingLotId,
    required String vehicleTypeId,
    String? floorId,
    String? zoneId,
  }) async {
    final response = await dataSource.getAvailableSlots(
      parkingLotId: parkingLotId,
      vehicleTypeId: vehicleTypeId,
      floorId: floorId,
      zoneId: zoneId,
    );
    final List slotsData = response['availableSlots'] ?? [];
    return slotsData.map((json) => ParkingSlotModel.fromJson(json)).toList();
  }

  @override
  Future<List<AiSuggestion>> getAiSuggestions({
    required String parkingLotId,
    required String vehicleTypeId,
  }) async {
    final response = await dataSource.getAvailableSlots(
      parkingLotId: parkingLotId,
      vehicleTypeId: vehicleTypeId,
    );
    final recommendedSlotJson = response['recommendedSlot'];
    if (recommendedSlotJson == null) return [];

    final recommendedSlot = ParkingSlotModel.fromJson(recommendedSlotJson);

    // Convert to AiSuggestion
    return [
      AiSuggestion(
        id: 'ai_1',
        recommendedSlot: recommendedSlot,
        confidenceScore: 0.95,
        reason: 'Suggested by AI for optimal convenience',
        estimatedWalkTimeMinutes: 2,
        occupancyRate: 0.4,
        advantages: const ['Optimal routing', 'Near elevator'],
      ),
    ];
  }

  @override
  Future<bool> lockSlot(String slotId) => dataSource.lockSlot(slotId);

  @override
  Future<bool> unlockSlot(String slotId) => dataSource.unlockSlot(slotId);

  @override
  Future<Booking> createBooking({
    required String parkingLotId,
    required String vehicleTypeId,
    required DateTime scheduledDate,
    required String startTime,
    required String endTime,
    String? vehicleId,
    String? floorId,
    String? zoneId,
  }) => dataSource.createBooking(
    parkingLotId: parkingLotId,
    vehicleTypeId: vehicleTypeId,
    scheduledDate: scheduledDate,
    startTime: startTime,
    endTime: endTime,
    vehicleId: vehicleId,
    floorId: floorId,
    zoneId: zoneId,
  );

  @override
  Future<Booking> getBookingById(String bookingId) =>
      dataSource.getBookingById(bookingId);

  @override
  Future<List<Booking>> getUserBookings() => dataSource.getMyBookings();

  @override
  Future<void> cancelBooking(String bookingId, String reason) =>
      dataSource.cancelBooking(bookingId, reason);
}
