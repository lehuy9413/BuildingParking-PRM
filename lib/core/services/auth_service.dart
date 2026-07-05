import 'package:shared_preferences/shared_preferences.dart';

/// Singleton quản lý auth token & thông tin user sau login.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _userRole;
  String? _assignedParkingLotId;
  String? _userFullName;

  // ─── Getters ───────────────────────────────────────────────────────────────

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get userRole => _userRole;
  String? get assignedParkingLotId => _assignedParkingLotId;
  String? get userFullName => _userFullName;

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  bool get isStaff =>
      _userRole == 'parking_staff' || _userRole == 'parking_manager';

  // ─── Save after login ──────────────────────────────────────────────────────

  Future<void> saveAuth({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = user['id']?.toString();
    _userRole = user['role']?.toString();
    _assignedParkingLotId = user['assignedParkingLot']?.toString();
    _userFullName = user['fullName']?.toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userId', _userId ?? '');
    await prefs.setString('userRole', _userRole ?? '');
    await prefs.setString('assignedParkingLotId', _assignedParkingLotId ?? '');
    await prefs.setString('userFullName', _userFullName ?? '');
  }

  /// Load from local storage on app start
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    _userId = prefs.getString('userId');
    _userRole = prefs.getString('userRole');
    _assignedParkingLotId = prefs.getString('assignedParkingLotId');
    _userFullName = prefs.getString('userFullName');
  }

  /// Update access token (after refresh)
  void updateAccessToken(String newToken) {
    _accessToken = newToken;
  }

  /// Clear on logout
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userRole = null;
    _assignedParkingLotId = null;
    _userFullName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
