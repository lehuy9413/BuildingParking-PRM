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
    required String plateNumber,
    required String vehicleTypeId,
    required String vehicleTypeName,
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
      );

      final session = _apiModelToSession(apiSession);
      _sessions.add(session);
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

      // Thêm vào danh sách local nếu chưa có
      final exists = _sessions.any((s) => s.id == session.id);
      if (!exists) _sessions.add(session);

      selectedCheckoutSession = session;
      totalFee = apiSession.totalFee > 0 ? apiSession.totalFee : session.calculateFee(); // Hiển thị phí tạm tính khi chưa checkout
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
    totalFee = session.calculateFee();
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
    checkoutApiSession = null;
    totalFee = 0;
    notifyListeners();
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
    );
  }
}