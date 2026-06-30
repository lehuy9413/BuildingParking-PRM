import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/booking_model.dart';
import '../models/parking_lot_model.dart';

import '../models/vehicle_model.dart';

class ApiBookingDataSource {
  final Dio dio = ApiClient.instance.dio;

  Future<List<ParkingLotModel>> getParkingLots() async {
    final response = await dio.get(ApiEndpoints.parkingLots);
    if (response.statusCode == 200) {
      final List data = response.data['data']['docs'] ?? [];
      return data.map((json) => ParkingLotModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load parking lots');
  }

  Future<List<VehicleModel>> getMyVehicles() async {
    final response = await dio.get(ApiEndpoints.vehicles);
    if (response.statusCode == 200) {
      final List data = response.data['data'] ?? [];
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load vehicles');
  }

  Future<Map<String, dynamic>> getAvailableSlots({
    required String parkingLotId,
    required String vehicleTypeId,
    String? floorId,
    String? zoneId,
  }) async {
    final queryParams = {
      'parkingLotId': parkingLotId,
      'vehicleTypeId': vehicleTypeId,
      'floorId': ?floorId,
      'zoneId': ?zoneId,
    };
    final response = await dio.get(
      ApiEndpoints.availableSlots,
      queryParameters: queryParams,
    );
    if (response.statusCode == 200) {
      return response.data['data'];
    }
    throw Exception('Failed to get available slots');
  }

  Future<bool> lockSlot(String slotId) async {
    final response = await dio.post(ApiEndpoints.lockSlot(slotId));
    return response.statusCode == 200;
  }

  Future<bool> unlockSlot(String slotId) async {
    final response = await dio.delete(ApiEndpoints.unlockSlot(slotId));
    return response.statusCode == 200;
  }

  Future<BookingModel> createBooking({
    required String parkingLotId,
    required String vehicleTypeId,
    required DateTime scheduledDate,
    required String startTime,
    required String endTime,
    String? vehicleId,
    String? floorId,
    String? zoneId,
  }) async {
    final body = {
      'parkingLot': parkingLotId,
      'vehicleType': vehicleTypeId,
      'scheduledDate': scheduledDate.toIso8601String().split('T').first,
      'startTime': startTime,
      'endTime': endTime,
      'vehicleId': ?vehicleId,
      'floorId': ?floorId,
      'zoneId': ?zoneId,
    };
    try {
      final response = await dio.post(ApiEndpoints.bookings, data: body);
      if (response.statusCode == 201) {
        return BookingModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create booking');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo booking');
      }
      throw Exception('Network error');
    }
  }

  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await dio.get('${ApiEndpoints.bookings}/$bookingId');
    if (response.statusCode == 200) {
      return BookingModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to load booking');
  }

  Future<List<BookingModel>> getMyBookings() async {
    final response = await dio.get(ApiEndpoints.myBookings);
    if (response.statusCode == 200) {
      final List data = response.data['data']['docs'] ?? [];
      return data.map((json) => BookingModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load my bookings');
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    final response = await dio.patch(
      '${ApiEndpoints.bookings}/$bookingId/cancel',
      data: {'reason': reason},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking');
    }
  }
}
