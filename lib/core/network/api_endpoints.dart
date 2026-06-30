class ApiEndpoints {
  static const String baseUrl = 'https://parking-backend-prm.onrender.com/api/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // Booking endpoints
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';

  // Parking Lots
  static const String parkingLots = '/parking-lots';

  // Parking Slots
  static const String availableSlots = '/parking-slots/available';
  static String lockSlot(String id) => '/parking-slots/$id/lock';
  static String unlockSlot(String id) => '/parking-slots/$id/lock'; // DELETE request

  // Vehicles
  static const String vehicles = '/vehicles';
  static const String defaultVehicle = '/vehicles/default';
}