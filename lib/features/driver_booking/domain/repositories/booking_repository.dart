import '../entities/booking.dart';
import '../entities/parking_slot.dart';
import '../entities/ai_suggestion.dart';

abstract class BookingRepository {
  Future<List<ParkingSlot>> getAvailableSlots({
    required VehicleType vehicleType,
    required ParkingZone zone,
    required DateTime dateTime,
  });

  Future<Booking> createBooking({
    required String slotId,
    required VehicleType vehicleType,
    required String? licensePlate,
    required DateTime checkInTime,
    required DateTime checkOutTime,
  });

  Future<Booking> getBookingById(String bookingId);
  Future<List<Booking>> getUserBookings();
  Future<void> cancelBooking(String bookingId);

  Future<List<AiSuggestion>> getAiSuggestions({
    required VehicleType vehicleType,
    required DateTime dateTime,
  });
}
