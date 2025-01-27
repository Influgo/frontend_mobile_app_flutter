import 'package:frontend_mobile_app_flutter/features/authentication/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase({required this.repository});

  Future<void> execute(String email) async {
    return await repository.sendPasswordResetRequest(email);
  }
}
