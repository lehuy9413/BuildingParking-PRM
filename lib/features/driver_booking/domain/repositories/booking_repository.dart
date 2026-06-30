import '../entities/booking.dart';
import '../entities/parking_slot.dart';
import '../entities/ai_suggestion.dart';
import '../entities/parking_lot.dart';
import '../entities/vehicle.dart';

abstract class BookingRepository {
  Future<List<ParkingLot>> getParkingLots();
  
  Future<List<Vehicle>> getMyVehicles();
  
  Future<List<ParkingSlot>> getAvailableSlots({
    required String parkingLotId,
    required String vehicleTypeId,
    String? floorId,
    String? zoneId,
  });

  Future<List<AiSuggestion>> getAiSuggestions({
    required String parkingLotId,
    required String vehicleTypeId,
  });

  Future<bool> lockSlot(String slotId);
  
  Future<bool> unlockSlot(String slotId);

  Future<Booking> createBooking({
    required String parkingLotId,
    required String vehicleTypeId,
    required DateTime scheduledDate,
    required String startTime,
    required String endTime,
    String? vehicleId,
    String? floorId,
    String? zoneId,
  });

  Future<Booking> getBookingById(String bookingId);
  
  Future<List<Booking>> getUserBookings();
  
  Future<void> cancelBooking(String bookingId, String reason);
}
