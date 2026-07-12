import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cliente HTTP centralizado hacia el backend Django REST Framework.
///
/// Cambia [baseUrl] según el entorno:
/// - Emulador Android -> http://10.0.2.2:8000/api
/// - Dispositivo físico en la misma red -> http://<ip-local>:8000/api
/// - Producción (Render) -> https://<app>.onrender.com/api
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> get accessToken => _storage.read(key: 'access_token');
}
