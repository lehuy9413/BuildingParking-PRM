import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/driver_tracking_datasource.dart';
import '../../../staff_core/data/models/parking_session_api_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LIVE SESSION
// ─────────────────────────────────────────────────────────────────────────────

class LiveSessionState {
  final List<ParkingSessionApiModel> sessions;
  final bool isLoading;
  final String? error;

  const LiveSessionState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  /// Backward-compat: first active session (used by LiveSessionScreen)
  ParkingSessionApiModel? get session => sessions.isNotEmpty ? sessions.first : null;

  bool get hasActiveSession => sessions.isNotEmpty;

  LiveSessionState copyWith({
    List<ParkingSessionApiModel>? sessions,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LiveSessionState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LiveSessionController extends AsyncNotifier<LiveSessionState> {
  late final DriverTrackingDatasource _ds;

  @override
  Future<LiveSessionState> build() async {
    _ds = DriverTrackingDatasource();
    return _fetchSessions();
  }

  Future<LiveSessionState> _fetchSessions() async {
    try {
      final sessions = await _ds.getMyActiveSessions();
      return LiveSessionState(sessions: sessions);
    } catch (e) {
      return LiveSessionState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSessions());
  }
}

final liveSessionProvider =
    AsyncNotifierProvider<LiveSessionController, LiveSessionState>(
        LiveSessionController.new);

// ─────────────────────────────────────────────────────────────────────────────
// PARKING HISTORY
// ─────────────────────────────────────────────────────────────────────────────

class ParkingHistoryState {
  final List<ParkingSessionApiModel> sessions;
  final bool isLoading;
  final String? error;

  const ParkingHistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalSpent =>
      sessions.fold(0.0, (sum, s) => sum + s.totalFee);
}

class ParkingHistoryController extends AsyncNotifier<ParkingHistoryState> {
  late final DriverTrackingDatasource _ds;

  @override
  Future<ParkingHistoryState> build() async {
    _ds = DriverTrackingDatasource();
    return _fetch();
  }

  Future<ParkingHistoryState> _fetch() async {
    try {
      final sessions = await _ds.getMySessionHistory();
      return ParkingHistoryState(sessions: sessions);
    } catch (e) {
      return ParkingHistoryState(error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final parkingHistoryProvider =
    AsyncNotifierProvider<ParkingHistoryController, ParkingHistoryState>(
        ParkingHistoryController.new);

// ─────────────────────────────────────────────────────────────────────────────
// QR PAYMENT
// ─────────────────────────────────────────────────────────────────────────────

enum QrPaymentStep { idle, loading, showQr, polling, success, failed }

class QrPaymentState {
  final QrPaymentStep step;
  final String? qrData;
  final String? paymentId;
  final String? transferContent;
  final String? bankInfo;
  final String? error;

  const QrPaymentState({
    this.step = QrPaymentStep.idle,
    this.qrData,
    this.paymentId,
    this.transferContent,
    this.bankInfo,
    this.error,
  });

  QrPaymentState copyWith({
    QrPaymentStep? step,
    String? qrData,
    String? paymentId,
    String? transferContent,
    String? bankInfo,
    String? error,
    bool clearError = false,
  }) {
    return QrPaymentState(
      step: step ?? this.step,
      qrData: qrData ?? this.qrData,
      paymentId: paymentId ?? this.paymentId,
      transferContent: transferContent ?? this.transferContent,
      bankInfo: bankInfo ?? this.bankInfo,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class QrPaymentController extends Notifier<QrPaymentState> {
  final DriverTrackingDatasource _ds = DriverTrackingDatasource();
  Timer? _pollTimer;

  @override
  QrPaymentState build() {
    ref.onDispose(() => _pollTimer?.cancel());
    return const QrPaymentState();
  }

  Future<void> initiateQr(String sessionId) async {
    state = state.copyWith(step: QrPaymentStep.loading, clearError: true);
    try {
      final result = await _ds.initiateQrPayment(sessionId);
      final paymentId = result['paymentId']?.toString() ??
          result['payment']?['_id']?.toString() ??
          result['_id']?.toString();
      final qrData = result['qrUrl']?.toString() ??
          result['qrCode']?.toString() ??
          result['transferContent']?.toString() ??
          'PAYMENT|$sessionId';

      state = state.copyWith(
        step: QrPaymentStep.showQr,
        qrData: qrData,
        paymentId: paymentId,
        transferContent: result['transferContent']?.toString(),
        bankInfo: result['bankInfo']?.toString(),
      );

      if (paymentId != null) {
        _startPolling(paymentId);
      }
    } catch (e) {
      state = state.copyWith(
        step: QrPaymentStep.failed,
        error: e.toString(),
      );
    }
  }

  void _startPolling(String paymentId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final status = await _ds.checkQrPaymentStatus(paymentId);
      if (status == 'paid' || status == 'completed') {
        _pollTimer?.cancel();
        state = state.copyWith(step: QrPaymentStep.success);
      } else if (status == 'failed' || status == 'cancelled') {
        _pollTimer?.cancel();
        state = state.copyWith(
            step: QrPaymentStep.failed, error: 'Thanh toán thất bại');
      }
    });
  }

  void reset() {
    _pollTimer?.cancel();
    state = const QrPaymentState();
  }
}

final qrPaymentProvider =
    NotifierProvider<QrPaymentController, QrPaymentState>(
        QrPaymentController.new);

// ─────────────────────────────────────────────────────────────────────────────
// FEEDBACK
// ─────────────────────────────────────────────────────────────────────────────

enum FeedbackSubmitStatus { idle, loading, success, failed }

class FeedbackState {
  final FeedbackSubmitStatus status;
  final String? feedbackId;
  final String? error;

  const FeedbackState({
    this.status = FeedbackSubmitStatus.idle,
    this.feedbackId,
    this.error,
  });

  FeedbackState copyWith({
    FeedbackSubmitStatus? status,
    String? feedbackId,
    String? error,
    bool clearError = false,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      feedbackId: feedbackId ?? this.feedbackId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FeedbackController extends Notifier<FeedbackState> {
  final DriverTrackingDatasource _ds = DriverTrackingDatasource();

  @override
  FeedbackState build() => const FeedbackState();

  Future<void> submit({
    required String title,
    required String content,
    required int rating,
    required String type,
    String? parkingLotId,
  }) async {
    state = state.copyWith(
        status: FeedbackSubmitStatus.loading, clearError: true);
    try {
      final result = await _ds.submitFeedback(
        title: title,
        content: content,
        rating: rating,
        type: type,
        parkingLotId: parkingLotId,
      );
      final id = result['_id']?.toString() ?? result['id']?.toString();
      state = state.copyWith(
        status: FeedbackSubmitStatus.success,
        feedbackId: id,
      );
    } catch (e) {
      state = state.copyWith(
        status: FeedbackSubmitStatus.failed,
        error: e.toString(),
      );
    }
  }

  void reset() => state = const FeedbackState();
}

final feedbackProvider =
    NotifierProvider<FeedbackController, FeedbackState>(FeedbackController.new);