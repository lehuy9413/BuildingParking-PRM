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
      final responseData = response.data['data'];
      final List data = (responseData is Map && responseData.containsKey('docs'))
          ? responseData['docs']
          : (responseData is List ? responseData : []);
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

  Future<dynamic> getAvailableSlots({
    required String parkingLotId,
    required String vehicleTypeId,
    String? floorId,
    String? zoneId,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
  }) async {
    final queryParams = <String, dynamic>{
      'parkingLot': parkingLotId, // The generic endpoint uses 'parkingLot' not 'parkingLotId'
      'vehicleType': vehicleTypeId,
      'limit': 1000, // Make sure we get all slots
    };
    if (floorId != null) queryParams['floor'] = floorId;
    if (zoneId != null) queryParams['zone'] = zoneId;
    if (scheduledDate != null) queryParams['scheduledDate'] = scheduledDate.toIso8601String().split('T').first;
    if (startTime != null) queryParams['startTime'] = startTime;
    if (endTime != null) queryParams['endTime'] = endTime;

    // ignore: avoid_print
    print('[ApiBookingDataSource] GET /parking-slots params=$queryParams');
    final response = await dio.get(
      '/parking-slots',
      queryParameters: queryParams,
    );
    // ignore: avoid_print
    print('[ApiBookingDataSource] Response status=${response.statusCode}, data keys=${response.data?.keys}');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      // ignore: avoid_print
      print('[ApiBookingDataSource] Type of data: ${data.runtimeType}');
      if (data is Map) {
        // ignore: avoid_print
        print('[ApiBookingDataSource] Data keys: ${data.keys}');
      }
      return data ?? response.data;
    }
    throw Exception('Failed to get available slots: ${response.statusCode}');
  }

  Future<dynamic> getAiSuggestions({
    required String parkingLotId,
    required String vehicleTypeId,
  }) async {
    final response = await dio.get(
      '/parking-slots/available',
      queryParameters: {
        'parkingLotId': parkingLotId,
        'vehicleTypeId': vehicleTypeId,
      },
    );
    if (response.statusCode == 200) {
      return response.data['data'] ?? response.data;
    }
    throw Exception('Failed to get AI suggestions');
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
    String? licensePlate,
    String? floorId,
    String? zoneId,
    String? assignedSlot,
  }) async {
    final body = <String, dynamic>{
      'parkingLot': parkingLotId,
      'vehicleType': vehicleTypeId,
      'scheduledDate': scheduledDate.toUtc().toIso8601String(), // Ensure full ISO with Z
      'startTime': startTime,
      'endTime': endTime,
    };
    if (licensePlate != null) {
      body['vehicleInfo'] = {'licensePlate': licensePlate};
    }
    if (floorId != null) body['floorId'] = floorId;
    if (zoneId != null) body['zoneId'] = zoneId;
    if (assignedSlot != null) body['assignedSlot'] = assignedSlot;
    try {
      final response = await dio.post(ApiEndpoints.bookings, data: body);
      if (response.statusCode == 201) {
        return BookingModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create booking');
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[ApiBookingDataSource] 422 Error Payload: $body');
      // ignore: avoid_print
      print('[ApiBookingDataSource] 422 Error Response: ${e.response?.data}');
      if (e.response != null && e.response?.data != null) {
        final errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Lỗi khi tạo booking';
        throw Exception(errorMsg);
      }
      throw Exception('Network error: ${e.message}');
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
      final responseData = response.data['data'];
      final List data = (responseData is Map && responseData.containsKey('docs'))
          ? responseData['docs']
          : (responseData is List ? responseData : []);
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

  Future<List<dynamic>> getVehicleTypes() async {
    final response = await dio.get(ApiEndpoints.vehicleTypes);
    if (response.statusCode == 200) {
      final data = response.data['data'];
      return (data is List) ? data : (data['docs'] ?? []);
    }
    throw Exception('Failed to get vehicle types');
  }
}
