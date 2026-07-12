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
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => _client.clearTokens();

  Future<bool> isLoggedIn() async => (await _client.accessToken) != null;
}
