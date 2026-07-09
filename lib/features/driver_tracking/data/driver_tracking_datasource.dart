import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../staff_core/data/models/parking_session_api_model.dart';

/// Datasource cho tất cả chức năng Driver Tracking:
/// - Live Session (phiên đỗ xe hiện tại)
/// - Parking History (lịch sử gửi xe + booking)
/// - Payment (bank-transfer QR)
/// - Feedback (gửi phản hồi / báo sự cố)
class DriverTrackingDatasource {
  final Dio _dio = ApiClient.instance.dio;

  // ─── LIVE SESSION ─────────────────────────────────────────────────────────

  /// Lấy phiên đỗ xe đang active của driver hiện tại.
  /// Backend lọc theo user đang đăng nhập (JWT).
  Future<ParkingSessionApiModel?> getMyActiveSession() async {
    try {
      final res = await _dio.get(
        ApiEndpoints.sessions,
        queryParameters: {'status': 'active', 'limit': 1},
      );
      final data = res.data['data'];
      final List docs = data is List ? data : (data['docs'] ?? []);
      if (docs.isEmpty) return null;
      return ParkingSessionApiModel.fromJson(docs.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── PARKING HISTORY ─────────────────────────────────────────────────────

  /// Lấy toàn bộ lịch sử phiên đỗ xe (completed) của driver.
  Future<List<ParkingSessionApiModel>> getMySessionHistory() async {
    try {
      final res = await _dio.get(
        ApiEndpoints.sessions,
        queryParameters: {'status': 'completed', 'limit': 50},
      );
      final data = res.data['data'];
      final List docs = data is List ? data : (data['docs'] ?? []);
      return docs
          .map((e) => ParkingSessionApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── PAYMENT ─────────────────────────────────────────────────────────────

  /// Khởi tạo thanh toán bank transfer QR cho SESSION checkout.
  /// ⚠️  /payments/bank-transfer/initiate chỉ dành cho staff.
  /// Driver dùng qua endpoint mở hơn hoặc hiển thị VietQR static từ session info.
  /// Ở đây FE tự build VietQR URL từ sessionId và amount (không cần backend).
  Future<Map<String, dynamic>> initiateQrPayment(String sessionId) async {
    // Thử gọi API trước; nếu 403 thì tự build QR từ config
    try {
      final res = await _dio.post(
        ApiEndpoints.bankTransferInitiate,
        data: {'sessionId': sessionId},
      );
      final data = res.data['data'];
      return (data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 ||
          e.response?.statusCode == 401) {
        // Driver không có quyền – build VietQR locally
        return _buildLocalVietQr(sessionId);
      }
      throw _handleError(e);
    }
  }

  /// Build VietQR URL locally khi driver không có quyền gọi staff endpoint.
  /// Lấy thông tin bank từ session để tạo QR chuẩn VietQR.
  Map<String, dynamic> _buildLocalVietQr(String sessionId) {
    const bankId = 'MB';
    const accountNumber = '0342347435';
    const accountName = 'PARKINGBUILDING';
    final transferContent = 'PARK${sessionId.substring(sessionId.length > 6 ? sessionId.length - 6 : 0).toUpperCase()}';
    final qrUrl =
        'https://img.vietqr.io/image/$bankId-$accountNumber-compact.jpg'
        '?addInfo=${Uri.encodeComponent(transferContent)}'
        '&accountName=${Uri.encodeComponent(accountName)}';
    return {
      'qrUrl': qrUrl,
      'transferContent': transferContent,
      'bankInfo': '$bankId – $accountNumber ($accountName)',
    };
  }

  /// Kiểm tra trạng thái thanh toán QR.
  /// BE trả về status: 'completed' khi đã thanh toán (không phải 'paid').
  Future<String> checkQrPaymentStatus(String paymentId) async {
    try {
      final res = await _dio.get(ApiEndpoints.bankTransferStatus(paymentId));
      // Backend checkBankTransferStatus returns { status, isPaid, ... }
      final data = res.data['data'];
      final isPaid = data?['isPaid'] == true;
      if (isPaid) return 'paid';
      return data?['status']?.toString() ?? 'pending';
    } on DioException catch (_) {
      return 'pending';
    }
  }

  /// Thanh toán tiền mặt (driver tự báo – thực ra staff thường làm điều này,
  /// nhưng driver cũng có thể xem trạng thái).
  Future<Map<String, dynamic>> processCashPayment({
    required String sessionId,
    required double cashReceived,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.cashPayment,
        data: {'sessionId': sessionId, 'cashReceived': cashReceived},
      );
      return (res.data['data'] as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── FEEDBACK ─────────────────────────────────────────────────────────────

  /// Gửi feedback/report tới hệ thống.
  /// ⚠️  BE schema yêu cầu `parkingLot` (required: true).
  /// Nếu driver không truyền lotId, sẽ tự lấy từ session gần nhất.
  Future<Map<String, dynamic>> submitFeedback({
    required String title,
    required String content,
    required int rating,
    required String type,
    String? parkingLotId,
  }) async {
    try {
      // parkingLot là bắt buộc – tự resolve nếu chưa có
      String? lotId = parkingLotId;
      if (lotId == null || lotId.isEmpty) {
        lotId = await _resolveParkingLotId();
      }
      if (lotId == null || lotId.isEmpty) {
        throw 'Không tìm thấy thông tin bãi xe. Vui lòng thử lại sau khi bạn có lịch sử gửi xe.';
      }

      final body = <String, dynamic>{
        'title': title,
        'content': content,
        'rating': rating,
        'type': type,
        'parkingLot': lotId,
      };
      final res = await _dio.post(ApiEndpoints.feedbacks, data: body);
      return (res.data['data'] as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy parkingLotId từ session active hoặc session gần nhất (fallback).
  Future<String?> _resolveParkingLotId() async {
    try {
      // Thử session active trước
      final active = await getMyActiveSession();
      if (active != null && active.parkingLotId.isNotEmpty) {
        return active.parkingLotId;
      }
      // Fallback: session completed gần nhất
      final res = await _dio.get(
        ApiEndpoints.sessions,
        queryParameters: {'limit': 1, 'sort': '-entryTime'},
      );
      final data = res.data['data'];
      final List docs = data is List ? data : (data['docs'] ?? []);
      if (docs.isNotEmpty) {
        final session = ParkingSessionApiModel.fromJson(
            docs.first as Map<String, dynamic>);
        return session.parkingLotId.isNotEmpty ? session.parkingLotId : null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Error handling ──────────────────────────────────────────────────────

  String _handleError(DioException e) {
    if (e.response != null) {
      final msg = e.response?.data?['message'] ?? e.response?.data?['error'];
      final errors = e.response?.data?['errors'];
      if (errors != null && errors is List && errors.isNotEmpty) {
        return '$msg: ${errors.map((err) => err['message']).join(', ')}';
      }
      if (msg != null) return msg.toString();
      return 'Server error: ${e.response?.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Không thể kết nối server. Vui lòng kiểm tra mạng.';
    }
    return e.message ?? 'Unknown error';
  }
}
