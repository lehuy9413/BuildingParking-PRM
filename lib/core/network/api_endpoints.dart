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

  // Parking Sessions
  static const String checkIn = '/parking-sessions/check-in';
  static const String findActiveSession = '/parking-sessions/find-active';
  static String checkOut(String id) => '/parking-sessions/$id/check-out';
  static String sessionById(String id) => '/parking-sessions/$id';

  // Payments
  static const String cashPayment = '/payments/cash';
  static const String bankTransferInitiate = '/payments/bank-transfer/initiate';
  static String bankTransferStatus(String paymentId) => '/payments/bank-transfer/$paymentId/status';

  // Parking Lots
  static const String parkingLots = '/parking-lots';

  // Vehicle Types
  static const String vehicleTypes = '/vehicle-types';

  // Sessions list (for dashboard count)
  static const String sessions = '/parking-sessions';

  // LPR (License Plate Recognition)
  static const String lprRecognize = '/lpr/recognize';
}