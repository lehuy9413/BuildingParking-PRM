import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';
import '../models/parking_session_api_model.dart';
import '../models/vehicle_type_model.dart';

/// Datasource thực hiện tất cả API calls liên quan đến chức năng Staff.
class StaffRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  // ─── Vehicle Types ─────────────────────────────────────────────────────────

  /// Lấy danh sách loại xe từ server
  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    try {
      final res = await _dio.get(ApiEndpoints.vehicleTypes);
      final data = res.data['data'];
      final List docs = data is List ? data : (data['docs'] ?? data['vehicleTypes'] ?? []);
      return docs.map((e) => VehicleTypeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Parking Lots ─────────────────────────────────────────────────────────

  /// Lấy danh sách bãi xe (nếu cần)
  Future<List<Map<String, dynamic>>> getParkingLots() async {
    try {
      final res = await _dio.get(ApiEndpoints.parkingLots);
      final data = res.data['data'];
      final List docs = data is List ? data : (data['docs'] ?? []);
      return docs.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Dashboard ────────────────────────────────────────────────────────────

  /// Lấy danh sách xe đang trong bãi
  Future<List<ParkingSessionApiModel>> getActiveSessions() async {
    try {
      final lotId = AuthService.instance.assignedParkingLotId;
      final params = <String, dynamic>{'status': 'active', 'limit': 100};
      if (lotId != null && lotId.isNotEmpty) params['parkingLot'] = lotId;

      final res = await _dio.get(ApiEndpoints.sessions, queryParameters: params);
      final data = res.data['data'];
      final List docs = data is List ? data : (data['docs'] ?? []);
      return docs.map((e) => ParkingSessionApiModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy số xe đang trong bãi (active sessions)
  Future<int> getActiveSessionCount() async {
    try {
      final lotId = AuthService.instance.assignedParkingLotId;
      final params = <String, dynamic>{'status': 'active', 'limit': 1};
      if (lotId != null && lotId.isNotEmpty) params['parkingLot'] = lotId;

      final res = await _dio.get(ApiEndpoints.sessions, queryParameters: params);
      final pagination = res.data['data']?['pagination'];
      return (pagination?['total'] ?? 0) as int;
    } on DioException catch (_) {
      return 0;
    }
  }

  // ─── Check-in ─────────────────────────────────────────────────────────────

  /// Tạo phiên đỗ xe mới (walk-in check-in)
  /// [licensePlate] biển số xe
  /// [vehicleTypeId] MongoDB ObjectId của vehicle type
  /// [parkingLotId] MongoDB ObjectId của bãi xe
  Future<ParkingSessionApiModel> checkIn({
    required String licensePlate,
    required String vehicleTypeId,
    required String parkingLotId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.checkIn,
        data: {
          'licensePlate': licensePlate,
          'vehicleTypeId': vehicleTypeId,
          'parkingLotId': parkingLotId,
        },
      );
      return ParkingSessionApiModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload evidence image
  Future<void> uploadEvidence({
    required String sessionId,
    required String base64Image,
    String type = 'entry',
  }) async {
    try {
      final List<String> parts = base64Image.split(',');
      final String base64Str = parts.length > 1 ? parts[1] : parts[0];
      final List<int> bytes = base64Decode(base64Str);

      final formData = FormData();
      formData.fields.add(MapEntry('type', type));
      formData.files.add(MapEntry('images', MultipartFile.fromBytes(bytes, filename: 'evidence.jpg')));

      await _dio.post(
        '/parking-sessions/$sessionId/evidence',
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Find Active Session ───────────────────────────────────────────────────

  /// Tìm session đang active theo biển số hoặc session code
  Future<ParkingSessionApiModel> findActiveSession({
    String? licensePlate,
    String? sessionCode,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (licensePlate != null && licensePlate.isNotEmpty) {
        params['licensePlate'] = licensePlate;
      }
      if (sessionCode != null && sessionCode.isNotEmpty) {
        params['sessionCode'] = sessionCode;
      }
      final lotId = AuthService.instance.assignedParkingLotId;
      if (lotId != null && lotId.isNotEmpty) params['parkingLotId'] = lotId;

      final res = await _dio.get(
        ApiEndpoints.findActiveSession,
        queryParameters: params,
      );
      return ParkingSessionApiModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Check-out ────────────────────────────────────────────────────────────

  /// Check-out xe, tính phí, trả về session với totalFee
  Future<ParkingSessionApiModel> checkOut(String sessionId) async {
    try {
      final res = await _dio.patch(ApiEndpoints.checkOut(sessionId));
      return ParkingSessionApiModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Cash Payment ─────────────────────────────────────────────────────────

  /// Thanh toán tiền mặt
  /// [sessionId] ID session đã checkout
  /// [cashReceived] Số tiền khách đưa (>= totalFee)
  Future<Map<String, dynamic>> processCash({
    required String sessionId,
    required double cashReceived,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.cashPayment,
        data: {
          'sessionId': sessionId,
          'cashReceived': cashReceived,
        },
      );
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── QR / Bank Transfer Payment ───────────────────────────────────────────

  /// Tạo QR code chuyển khoản (VietQR / SEPay)
  /// Trả về: { qrUrl, transferContent, amount, bankInfo }
  Future<Map<String, dynamic>> initiateQrPayment(String sessionId) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.bankTransferInitiate,
        data: {'sessionId': sessionId},
      );
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Kiểm tra trạng thái thanh toán chuyển khoản
  Future<String> checkQrPaymentStatus(String paymentId) async {
    try {
      final res = await _dio.get(ApiEndpoints.bankTransferStatus(paymentId));
      return res.data['data']?['status']?.toString() ?? 'pending';
    } on DioException catch (_) {
      return 'pending';
    }
  }

  /// Gửi ảnh lên API LPR để lấy biển số
  Future<String> recognizeLicensePlate(String base64Image) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.lprRecognize,
        data: {'imageBase64': base64Image},
      );
      return res.data['data']?['licensePlate']?.toString() ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Error handling ───────────────────────────────────────────────────────

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
