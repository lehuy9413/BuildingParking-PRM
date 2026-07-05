class ApiEndpoints {
  static const String baseUrl = 'https://parking-backend-prm.onrender.com/api/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  static const String bookings = '/bookings';
}