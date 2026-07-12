import '../core/api_client.dart';
import '../models/member.dart';

class MemberService {
  final _client = ApiClient.instance;

  Future<Member> getMyProfile() async {
    final response = await _client.dio.get('/members/me/');
    return Member.fromJson(response.data);
  }

  /// Solo permite actualizar nombre, edad, altura, meta y nivel de
  /// actividad; el backend rechaza peso/medidas por diseño.
  Future<void> updateMyProfile(Map<String, dynamic> data) async {
    await _client.dio.patch('/members/me/', data: data);
  }
}
