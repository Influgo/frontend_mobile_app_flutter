import 'package:frontend_mobile_app_flutter/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/domain/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> sendPasswordResetRequest(String email) async {
    await remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<http.Response> checkTokenRequest(String token) async {
    return await remoteDataSource.requestCheckToken(token);
  }
}
