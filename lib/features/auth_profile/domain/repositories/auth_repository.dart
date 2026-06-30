import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Login
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Save tokens
        if (data['accessToken'] != null) {
          await _storage.write(key: _tokenKey, value: data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _storage.write(key: _refreshTokenKey, value: data['refreshToken']);
        }
        
        // Sometimes backend returns user in 'user' key
        final userData = data['user'] ?? data;
        return UserModel.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Login failed');
    }
  }

  // Register
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'] ?? data;
        return UserModel.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Registration failed');
    }
  }

  // Get Me
  Future<UserModel> getMe() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final response = await _dio.get(
        ApiEndpoints.me,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'] ?? data;
        return UserModel.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to get profile');
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
