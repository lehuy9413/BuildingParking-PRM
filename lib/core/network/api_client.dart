import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import 'api_endpoints.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _log(obj.toString()),
      ),
    ]);

  static void _log(String msg) {
    // Chỉ log trong debug mode
    assert(() {
      // ignore: avoid_print
      print('[API] $msg');
      return true;
    }());
  }
}

/// Tự động gắn Bearer token vào mọi request
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthService.instance.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Nếu 401 → thử refresh token
    if (err.response?.statusCode == 401) {
      final refreshToken = AuthService.instance.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          final res = await dio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );
          final newToken = res.data['data']['accessToken'] as String;
          AuthService.instance.updateAccessToken(newToken);

          // Retry original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retryRes = await dio.fetch(opts);
          return handler.resolve(retryRes);
        } catch (_) {
          // Refresh failed → clear auth
          await AuthService.instance.clear();
        }
      }
    }
    handler.next(err);
  }
}