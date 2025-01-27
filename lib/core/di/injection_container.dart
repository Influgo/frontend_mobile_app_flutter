import 'package:frontend_mobile_app_flutter/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/domain/repositories/auth_repository.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  _setupAuthDependencies();
}

void _setupAuthDependencies() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: getIt<http.Client>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  getIt.registerFactory<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(repository: getIt<AuthRepository>()),
  );
}
