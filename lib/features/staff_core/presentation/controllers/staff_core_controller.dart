import 'package:flutter/material.dart';
import '../../domain/models/parking_session.dart';

/// Controller quản lý toàn bộ state của Staff Core.
/// Dùng ChangeNotifier để rebuild UI khi có thay đổi.
class StaffCoreController extends ChangeNotifier {
  // ─── Sessions ──────────────────────────────────────────────────────────────
  final List<ParkingSession> _sessions = [];

  List<ParkingSession> get sessions => List.unmodifiable(_sessions);

  List<ParkingSession> get activeSessions =>
      _sessions.where((s) => s.isActive).toList();

  int get vehiclesIn => _sessions.length;
  int get vehiclesOut => _sessions.where((s) => s.isPaid).length;
  int get activeVehicleCount => activeSessions.length;

  // ─── Check-in state ────────────────────────────────────────────────────────
  ParkingSession? latestSession;

  // ─── Check-out state ───────────────────────────────────────────────────────
  ParkingSession? selectedCheckoutSession;
  double totalFee = 0.0;

  // ─── Sample plates ───────────────────────────────────────────────────────────
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

  // ─── Check-in ──────────────────────────────────────────────────────────────

  ParkingSession createSession({
    required String plateNumber,
    required String vehicleType,
    required String entryGate,
  }) {
    final id =
        'PS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final session = ParkingSession(
      id: id,
      plateNumber: plateNumber.toUpperCase(),
      vehicleType: vehicleType,
      entryGate: entryGate,
      suggestedArea: ParkingSession.suggestedAreaFor(vehicleType),
      checkInTime: DateTime.now(),
    );
    _sessions.add(session);
    latestSession = session;
    notifyListeners();
    return session;
  }

  // ─── Check-out ─────────────────────────────────────────────────────────────

  /// Tìm session đang active theo biển số hoặc session ID.
  ParkingSession? findActiveSession(String query) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) return null;
    try {
      return activeSessions.firstWhere(
        (s) =>
            s.plateNumber.toUpperCase() == q ||
            s.id.toUpperCase() == q,
      );
    } catch (_) {
      return null;
    }
  }

  void selectForCheckout(ParkingSession session) {
    selectedCheckoutSession = session;
    totalFee = session.calculateFee();
    notifyListeners();
  }

  void clearCheckoutSelection() {
    selectedCheckoutSession = null;
    totalFee = 0;
    notifyListeners();
  }

  /// Session active gần nhất – dùng cho nút "Scan Card/QR" sample.
  ParkingSession? get latestActiveSession =>
      activeSessions.isNotEmpty ? activeSessions.last : null;

  // ─── Payment ───────────────────────────────────────────────────────────────

  void confirmPayment() {
    if (selectedCheckoutSession == null) return;
    final idx =
        _sessions.indexWhere((s) => s.id == selectedCheckoutSession!.id);
    if (idx == -1) return;
    _sessions[idx] = _sessions[idx].copyWith(
      isPaid: true,
      checkOutTime: DateTime.now(),
    );
    selectedCheckoutSession = null;
    totalFee = 0;
    notifyListeners();
  }
}