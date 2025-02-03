import 'package:frontend_mobile_app_flutter/features/authentication/domain/repositories/auth_repository.dart';
import 'package:http/http.dart';

class CheckTokenUseCase {
  final AuthRepository repository;

  CheckTokenUseCase({required this.repository});

  Future<Response> execute(String token) async {
    return await repository.checkTokenRequest(token);
  }
}
