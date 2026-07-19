import 'package:flutter/material.dart';
import '../../domain/models/parking_session.dart';
import '../../data/datasources/staff_remote_datasource.dart';
import '../../data/models/parking_session_api_model.dart';
import '../../data/models/vehicle_type_model.dart';
import '../../../../core/services/auth_service.dart';

/// Controller quản lý toàn bộ state của Staff Core.
/// Dùng ChangeNotifier để rebuild UI khi có thay đổi.
class StaffCoreController extends ChangeNotifier {
  final StaffRemoteDatasource _datasource = StaffRemoteDatasource();

  // ─── Sessions ──────────────────────────────────────────────────────────────
  final List<ParkingSession> _sessions = [];

  List<ParkingSession> get sessions => List.unmodifiable(_sessions);
  List<ParkingSession> get activeSessions =>
      _sessions.where((s) => s.isActive).toList();

  int get vehiclesIn => _sessions.length;
  int get vehiclesOut => _sessions.where((s) => s.isPaid).length;
  int get activeVehicleCount => activeSessions.length;

  // ─── Vehicle Types từ API ──────────────────────────────────────────────────
  List<VehicleTypeModel> vehicleTypes = [];
  bool vehicleTypesLoading = false;

  // ─── Parking Lot (từ assignedParkingLot của staff) ─────────────────────────
  String? get assignedParkingLotId => AuthService.instance.assignedParkingLotId;

  // ─── Loading / Error state ─────────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;

  // ─── Check-in state ────────────────────────────────────────────────────────
  ParkingSession? latestSession;

  // ─── Check-out state ───────────────────────────────────────────────────────
  ParkingSession? selectedCheckoutSession;
  ParkingSessionApiModel? checkoutApiSession; // raw từ API sau checkout
  double totalFee = 0.0;

  // ─── Sample plates (giả lập OCR) ──────────────────────────────────────────
  static const List<String> _samplePlates = [
    '51A-12345',
    '59X1-88888',
    '30E-99999',
    '43B-55512',
    '29A-99001',
  ];
  int _samplePlateIndex = 0;

  String getSamplePlate() {
    final plate = _samplePlates[_samplePlateIndex % _samplePlates.length];
    _samplePlateIndex++;
    return plate;
  }

  // ─── LPR API Call ────────────────────────────────────────────────────────
  Future<String> recognizeLicensePlate(String base64Image) async {
    try {
      return await _datasource.recognizeLicensePlate(base64Image);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return '';
    }
  }

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await loadVehicleTypes();
    await loadActiveSessions();
  }

  Future<void> loadActiveSessions() async {
    try {
      final activeApiSessions = await _datasource.getActiveSessions();
      _sessions.clear();
      for (var apiSession in activeApiSessions) {
        _sessions.add(_apiModelToSession(apiSession));
      }
      notifyListeners();
    } catch (e) {
      // Bỏ qua lỗi nếu có
    }
  }

  Future<void> loadVehicleTypes() async {
    vehicleTypesLoading = true;
    notifyListeners();
    try {
      vehicleTypes = await _datasource.getVehicleTypes();
    } catch (e) {
      // fallback nếu API lỗi
      vehicleTypes = [];
    } finally {
      vehicleTypesLoading = false;
      notifyListeners();
    }
  }

  // ─── Check-in ──────────────────────────────────────────────────────────────

  /// Gọi API check-in thực tế.
  /// Trả về [ParkingSession] domain model để UI dùng.
  Future<ParkingSession> createSessionApi({
    String? plateNumber,
    String? vehicleTypeId,
    String? vehicleTypeName,
    String? bookingId,
  }) async {
    if (assignedParkingLotId == null || assignedParkingLotId!.isEmpty) {
      throw 'Staff is not assigned to a parking lot. Please contact Admin.';
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiSession = await _datasource.checkIn(
        licensePlate: plateNumber,
        vehicleTypeId: vehicleTypeId,
        parkingLotId: assignedParkingLotId!,
        bookingId: bookingId,
      );

      final session = _apiModelToSession(apiSession);
      _sessions.insert(0, session);
      latestSession = session;
      notifyListeners();
      return session;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadEvidence(String sessionId, String base64Image) async {
    try {
      await _datasource.uploadEvidence(
        sessionId: sessionId,
        base64Image: base64Image,
        type: 'entry',
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      // Silently fail or handle, it's just evidence
    }
  }

  // ─── Check-out ─────────────────────────────────────────────────────────────

  /// Tìm session đang active theo biển số hoặc session ID qua API.
  Future<ParkingSession?> findActiveSessionApi(String query) async {
    if (query.trim().isEmpty) return null;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final q = query.trim();
      // Nhận diện: nếu bắt đầu bằng PS- thì là session code, còn lại là plate
      final apiSession = q.toUpperCase().startsWith('PS-')
          ? await _datasource.findActiveSession(sessionCode: q)
          : await _datasource.findActiveSession(licensePlate: q);

      final session = _apiModelToSession(apiSession);

      final exists = _sessions.any((s) => s.id == session.id);
      if (!exists) _sessions.add(session);

      selectedCheckoutSession = session;
      checkoutApiSession = null;
      totalFee = calculatePreviewFee(session, apiSession.totalFee);
      notifyListeners();
      return session;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectForCheckout(ParkingSession session) {
    selectedCheckoutSession = session;
    checkoutApiSession = null;
    totalFee = calculatePreviewFee(session, session.totalFee);
    notifyListeners();
  }

  void clearCheckoutSelection() {
    selectedCheckoutSession = null;
    checkoutApiSession = null;
    totalFee = 0;
    notifyListeners();
  }

  /// Gọi API checkout thực → lấy totalFee chính xác từ server
  Future<ParkingSessionApiModel> checkOutApi(String sessionId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiSession = await _datasource.checkOut(sessionId);
      checkoutApiSession = apiSession;
      totalFee = apiSession.totalFee;

      // Cập nhật session trong list local
      final idx = _sessions.indexWhere((s) => s.id == sessionId);
      if (idx != -1) {
        _sessions[idx] = _apiModelToSession(apiSession);
        selectedCheckoutSession = _sessions[idx];
      }

      notifyListeners();
      return apiSession;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Payment ───────────────────────────────────────────────────────────────

  /// Thanh toán tiền mặt qua API
  Future<Map<String, dynamic>> confirmCashPaymentApi({
    required String sessionId,
    required double cashReceived,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await _datasource.processCash(
        sessionId: sessionId,
        cashReceived: cashReceived,
      );
      _markLocalPaid(sessionId);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo QR thanh toán chuyển khoản
  Future<Map<String, dynamic>> initiateQrPaymentApi(String sessionId) async {
    isLoading = true;
    notifyListeners();
    try {
      return await _datasource.initiateQrPayment(sessionId);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Kiểm tra trạng thái QR payment
  Future<String> checkQrStatus(String paymentId) async {
    return _datasource.checkQrPaymentStatus(paymentId);
  }

  void _markLocalPaid(String sessionId) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _sessions[idx] = _sessions[idx].copyWith(
        isPaid: true,
        checkOutTime: DateTime.now(),
      );
    }
    selectedCheckoutSession = null;
    selectedCheckoutSession = null;
    checkoutApiSession = null;
    totalFee = 0;
    notifyListeners();
  }

  /// Tính phí dự kiến để hiển thị cho UI (nếu API chưa trả totalFee)
  double calculatePreviewFee(ParkingSession session, double apiFee) {
    if (apiFee > 0) return apiFee;
    if (session.vehicleType.isEmpty) return 0.0;

    final entryTime = session.checkInTime;
    final exitTime = DateTime.now();
    final durationMs = exitTime.difference(entryTime).inMilliseconds;
    if (durationMs <= 0) return 0.0;

    final vehicleTypeModel = vehicleTypes.firstWhere(
      (v) => v.name == session.vehicleType,
      orElse: () => VehicleTypeModel(
        id: '',
        name: session.vehicleType,
        code: '',
        dayBlockRate: 0,
        dailyRate: 0,
        nightBlockRate: 0,
      ),
    );

    final double dayBlockRate = vehicleTypeModel.dayBlockRate;
    final double nightBlockRate = vehicleTypeModel.nightBlockRate > 0 
        ? vehicleTypeModel.nightBlockRate 
        : (dayBlockRate * 1.5);

    double fee = 0.0;
    DateTime currentStart = entryTime;

    while (currentStart.isBefore(exitTime)) {
      DateTime blockEnd = currentStart.add(const Duration(hours: 4));
      if (blockEnd.isAfter(exitTime)) {
        blockEnd = exitTime;
      }
      
      final effectiveEnd = blockEnd.subtract(const Duration(milliseconds: 1));
      // Simulate backend timezone bugs:
      // - For walk-ins, backend uses new Date() which yields UTC hour (night block for 12:05 local)
      // - For bookings, backend parses string '12:05' as local time, yielding local hour (day block)
      final startHour = session.hasBooking ? currentStart.hour : currentStart.toUtc().hour;
      final endHour = session.hasBooking ? effectiveEnd.hour : effectiveEnd.toUtc().hour;

      final isStartNight = startHour >= 18 || startHour < 6;
      final isEndNight = endHour >= 18 || endHour < 6;
      final isNightBlock = isStartNight || isEndNight;

      if (isNightBlock) {
        fee += nightBlockRate;
      } else {
        fee += dayBlockRate;
      }

      currentStart = currentStart.add(const Duration(hours: 4));
    }

    return fee;
  }

  /// Session active gần nhất – dùng cho nút "Scan Card/QR" sample.
  ParkingSession? get latestActiveSession =>
      activeSessions.isNotEmpty ? activeSessions.last : null;

  // ─── Helper: API Model → Domain Model ─────────────────────────────────────

  ParkingSession _apiModelToSession(ParkingSessionApiModel api) {
    return ParkingSession(
      id: api.id,
      plateNumber: api.licensePlate,
      vehicleType: api.vehicleTypeName,
      entryGate: 'Gate A', // backend không track gate, giữ default
      suggestedArea: api.suggestedArea,
      checkInTime: api.entryTime,
      checkOutTime: api.exitTime,
      isPaid: api.isPaid,
      hasBooking: api.hasBooking,
      totalFee: api.totalFee,
    );
  }
}