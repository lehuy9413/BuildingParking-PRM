class ApiEndpoints {
  // Base URL – đổi sang IP máy thật nếu chạy trên Android/iOS device
  static const String baseUrl = 'https://parking-backend-prm.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Users & Vehicles
  static const String profile = '/users/profile';
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';
  static String vehicleSetDefault(String id) => '/vehicles/$id/default';
  static const String defaultVehicle = '/vehicles/default';

  // Booking endpoints
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';

  // Parking Sessions
  static const String checkIn = '/parking-sessions/check-in';
  static const String findActiveSession = '/parking-sessions/find-active';
  static String checkOut(String id) => '/parking-sessions/$id/check-out';
  static String sessionById(String id) => '/parking-sessions/$id';

  // Payments
  static const String cashPayment = '/payments/cash';
  static const String bankTransferInitiate = '/payments/bank-transfer/initiate';
  static const String bankTransferBookingInitiate = '/payments/bank-transfer/booking/initiate';
  static String bankTransferStatus(String paymentId) => '/payments/bank-transfer/$paymentId/status';

  // Parking Lots
  static const String parkingLots = '/parking-lots';

  // Vehicle Types
  static const String vehicleTypes = '/vehicle-types';

  // Sessions list (for dashboard count)
  static const String sessions = '/parking-sessions';

  // LPR (License Plate Recognition)
  static const String lprRecognize = '/lpr/recognize';

  // Parking Slots
  static const String availableSlots = '/parking-slots/available';
  static String lockSlot(String id) => '/parking-slots/$id/lock';
  static String unlockSlot(String id) => '/parking-slots/$id/lock'; // DELETE request

  // Feedbacks
  static const String feedbacks = '/feedbacks';

  // Incidents
  static const String incidents = '/incidents';
}