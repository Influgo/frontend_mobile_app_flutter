import 'package:http/http.dart' as http;

abstract class AuthRepository {
  Future<void> sendPasswordResetRequest(String email);
  Future<http.Response> checkTokenRequest(String token);
}
