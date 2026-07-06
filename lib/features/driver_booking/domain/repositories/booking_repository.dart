import '../entities/booking.dart';
import '../entities/parking_slot.dart';
import '../entities/ai_suggestion.dart';
import '../entities/parking_lot.dart';
import '../entities/vehicle.dart';
import '../entities/vehicle_type.dart';

abstract class BookingRepository {
  Future<List<ParkingLot>> getParkingLots();
  
  Future<List<Vehicle>> getMyVehicles();
  
  Future<List<ParkingSlot>> getAvailableSlots({
    required String parkingLotId,
    required String vehicleTypeId,
    String? floorId,
    String? zoneId,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
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
    String? licensePlate,
    String? floorId,
    String? zoneId,
    String? assignedSlot,
    double? estimatedFee,
    int? estimatedDuration,
  });

  Future<Booking> getBookingById(String bookingId);
  
  Future<List<Booking>> getUserBookings();
  
  Future<void> cancelBooking(String bookingId, String reason);
  
  Future<List<VehicleType>> getVehicleTypes();
}
