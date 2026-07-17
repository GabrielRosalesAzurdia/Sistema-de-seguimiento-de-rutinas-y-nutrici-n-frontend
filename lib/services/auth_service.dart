import 'package:dio/dio.dart';
import '../core/api_client.dart';

class AuthService {
  final _client = ApiClient.instance;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.dio.post('/auth/login/', data: {
        'email': email,
        'password': password,
      });
      await _client.saveTokens(
        access: response.data['access'],
        refresh: response.data['refresh'],
      );
      await _client.saveMustChangePassword(
        response.data['must_change_password'] == true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => _client.clearTokens();

  Future<bool> isLoggedIn() async => (await _client.accessToken) != null;

  Future<bool> mustChangePassword() => _client.getMustChangePassword();

  /// Devuelve `null` en éxito, o un mensaje de error legible si falla
  /// (contraseña actual incorrecta, nueva contraseña no cumple los
  /// requisitos, etc. — se toma del primer error que devuelva el
  /// serializer del backend).
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      await _client.dio.post('/auth/change-password/', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      await _client.saveMustChangePassword(false);
      return null;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data.values.isNotEmpty) {
        final firstError = data.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
      return 'No se pudo cambiar la contraseña. Intenta de nuevo.';
    } catch (_) {
      return 'No se pudo cambiar la contraseña. Intenta de nuevo.';
    }
  }
}
