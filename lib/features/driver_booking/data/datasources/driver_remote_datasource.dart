import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../staff_core/data/models/vehicle_type_model.dart';

class DriverRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

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

  String _handleError(DioException e) {
    if (e.response != null) {
      final msg = e.response?.data?['message'] ?? e.response?.data?['error'];
      if (msg != null) return msg.toString();
      return 'Server error: ${e.response?.statusCode}';
    }
    return e.message ?? 'Unknown error';
  }
}
