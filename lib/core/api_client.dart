import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cliente HTTP centralizado hacia el backend Django REST Framework.
///
/// [baseUrl] se resuelve por entorno vía `--dart-define=API_BASE_URL=...`
/// (default: emulador Android). Ejemplos:
/// - Emulador Android (default) -> http://10.0.2.2:8000/api
/// - Simulador iOS / macOS      -> --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
/// - Dispositivo físico         -> --dart-define=API_BASE_URL=http://<ip-local>:8000/api
/// - Producción (Render)        -> --dart-define=API_BASE_URL=https://<app>.onrender.com/api
///
/// Ver mobile/README.md para el comando completo por entorno.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Si el access token expiró (401), se intenta refrescar una
          // sola vez con el refresh token guardado y se reintenta la
          // request original. Si el refresh también falla, se borran
          // los tokens (el usuario queda efectivamente deslogueado en
          // la próxima pantalla que consulte isLoggedIn()).
          if (error.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(
                  baseUrl: baseUrl,
                  connectTimeout: const Duration(seconds: 10),
                  receiveTimeout: const Duration(seconds: 10),
                ));
                final response = await refreshDio.post('/auth/refresh/',
                    data: {'refresh': refreshToken});
                final newAccess = response.data['access'] as String;
                await _storage.write(key: 'access_token', value: newAccess);

                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newAccess';
                final retryResponse = await _dio.fetch(retryOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                await clearTokens();
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  Future<void> saveTokens(
      {required String access, required String refresh}) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await saveMustChangePassword(false);
  }

  Future<String?> get accessToken => _storage.read(key: 'access_token');

  /// No es secreto como los tokens (solo un flag de UX), pero necesita
  /// sobrevivir cold-starts para que SplashScreen respete el flujo
  /// obligatorio de "Crear tu contraseña" si el usuario cerró la app a
  /// mitad del flujo (login con contraseña temporal, ver ChangePasswordScreen).
  Future<void> saveMustChangePassword(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('must_change_password', value);
  }

  Future<bool> getMustChangePassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('must_change_password') ?? false;
  }

  /// En iOS/macOS, el Keychain (donde vive flutter_secure_storage)
  /// puede sobrevivir al desinstalado de la app — a diferencia de
  /// Android, donde sí se borra. Esto hace que un token de una
  /// instalación anterior parezca una sesión válida y la app salte el
  /// Login. `SharedPreferences` (NSUserDefaults en iOS) sí se borra al
  /// desinstalar, así que se usa como señal confiable de "primer
  /// arranque tras instalar" para invalidar cualquier token viejo que
  /// haya quedado del Keychain.
  static Future<void> clearStaleTokensOnFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool('has_launched_before') ?? false;
    if (!hasLaunchedBefore) {
      try {
        await instance.clearTokens();
      } catch (_) {
        // Best-effort: en macOS desktop sin el entitlement de
        // Keychain configurado (com.apple.security.app-sandbox sin
        // keychain-access-groups), flutter_secure_storage puede
        // lanzar una PlatformException aquí. No es el target real
        // del proyecto (solo Android en v1) — no debe tumbar el
        // arranque de la app en un entorno de desarrollo.
      }
      await prefs.setBool('has_launched_before', true);
    }
  }
}
