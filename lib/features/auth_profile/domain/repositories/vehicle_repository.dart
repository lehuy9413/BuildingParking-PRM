import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<VehicleModel>> getMyVehicles() async {
    try {
      final response = await _dio.get(ApiEndpoints.vehicles);
      if (response.statusCode == 200) {
        final body = response.data;
        final data = body['data'] ?? body;
        final List docs = data is List ? data : (data['docs'] ?? []);
        return docs.map((e) => VehicleModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get vehicles');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to get vehicles');
    }
  }

  Future<VehicleModel> addVehicle({
    required String licensePlate,
    required String vehicleType, // ID of vehicleType
    bool isDefault = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.vehicles,
        data: {
          'licensePlate': licensePlate,
          'vehicleType': vehicleType,
          'isDefault': isDefault,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = response.data;
        final data = body['data'] ?? body;
        final vehicleData = data['vehicle'] ?? data;
        return VehicleModel.fromJson(vehicleData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add vehicle');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to add vehicle');
    }
  }

  Future<VehicleModel> updateVehicle(String id, {
    required String licensePlate,
    required String vehicleType,
    bool? isDefault,
  }) async {
    try {
      final Map<String, dynamic> dataPayload = {
        'licensePlate': licensePlate,
        'vehicleType': vehicleType,
      };
      if (isDefault != null) {
        dataPayload['isDefault'] = isDefault;
      }
      final response = await _dio.put(
        ApiEndpoints.vehicleById(id),
        data: dataPayload,
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final data = body['data'] ?? body;
        final vehicleData = data['vehicle'] ?? data;
        return VehicleModel.fromJson(vehicleData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update vehicle');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to update vehicle');
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final response = await _dio.delete(ApiEndpoints.vehicleById(id));
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete vehicle');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to delete vehicle');
    }
  }

  Future<void> setDefaultVehicle(String id) async {
    try {
      final response = await _dio.patch(ApiEndpoints.vehicleSetDefault(id));
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to set active vehicle');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to set active vehicle');
    }
  }
}
