abstract class AuthRepository {
  Future<void> sendPasswordResetRequest(String email);
}
