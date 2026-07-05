import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';
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
        final body = response.data;
        final data = body['data'] ?? body;

        final accessToken = data['accessToken']?.toString() ?? '';
        final refreshToken = data['refreshToken']?.toString() ?? '';
        final userData = data['user'] ?? data;

        // Save to secure storage (legacy)
        final prefs = await SharedPreferences.getInstance();
        if (accessToken.isNotEmpty) {
          await _storage.write(key: _tokenKey, value: accessToken);
          await prefs.setString(_tokenKey, accessToken);
        }
        if (refreshToken.isNotEmpty) {
          await _storage.write(key: _refreshTokenKey, value: refreshToken);
          await prefs.setString(_refreshTokenKey, refreshToken);
        }

        // Save to AuthService singleton (dùng cho interceptor & controller)
        await AuthService.instance.saveAuth(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: Map<String, dynamic>.from(userData),
        );

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
        final body = response.data;
        final data = body['data'] ?? body;
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
      final prefs = await SharedPreferences.getInstance();
      String? token = await _storage.read(key: _tokenKey);
      token ??= prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        throw Exception('DEBUG: Token is null or empty locally. Please log out and log in again.');
      }

      final response = await _dio.get(
        ApiEndpoints.me,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final data = body['data'] ?? body;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
