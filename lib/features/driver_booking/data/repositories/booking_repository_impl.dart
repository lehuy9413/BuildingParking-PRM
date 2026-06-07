import '../../domain/entities/booking.dart';
import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/mock_booking_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final MockBookingDataSource dataSource;
  BookingRepositoryImpl({required this.dataSource});

  @override
  Future<List<ParkingSlot>> getAvailableSlots({
    required VehicleType vehicleType,
    required ParkingZone zone,
    required DateTime dateTime,
  }) => dataSource.getAvailableSlots(vehicleType: vehicleType, zone: zone, dateTime: dateTime);

  @override
  Future<Booking> createBooking({
    required String slotId,
    required VehicleType vehicleType,
    required String? licensePlate,
    required DateTime checkInTime,
    required DateTime checkOutTime,
  }) => dataSource.createBooking(
    slotId: slotId, vehicleType: vehicleType, licensePlate: licensePlate,
    checkInTime: checkInTime, checkOutTime: checkOutTime,
  );

  @override
  Future<Booking> getBookingById(String bookingId) => dataSource.getBookingById(bookingId);

  @override
  Future<List<Booking>> getUserBookings() => dataSource.getUserBookings();

  @override
  Future<void> cancelBooking(String bookingId) => dataSource.cancelBooking(bookingId);

  @override
  Future<List<AiSuggestion>> getAiSuggestions({
    required VehicleType vehicleType,
    required DateTime dateTime,
  }) => dataSource.getAiSuggestions(vehicleType: vehicleType, dateTime: dateTime);
}
