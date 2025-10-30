import 'package:get_it/get_it.dart';

// Auth domain/data
import 'package:sports_books/features/auth/domain/repositories/auth_repository.dart';
import 'package:sports_books/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sports_books/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:sports_books/features/auth/data/datasources/auth_remote_ds_mock.dart';
import 'package:sports_books/features/auth/data/mappers/user_mapper.dart';

// Auth usecases
import 'package:sports_books/features/auth/domain/usecases/sign_in_email_uc.dart';
import 'package:sports_books/features/auth/domain/usecases/sign_out_uc.dart';
import 'package:sports_books/features/auth/domain/usecases/register_uc.dart';
import 'package:sports_books/features/auth/domain/usecases/auth_state_stream_uc.dart';

final getIt = GetIt.instance;

void setupDi() {
  // datasource + mapper
  getIt.registerLazySingleton<AuthRemoteDs>(() => MockAuthRemoteDs());
  getIt.registerLazySingleton<UserMapper>(() => const UserMapper());

  // repository (GỌI THEO CONSTRUCTOR CÓ NAMED PARAMS)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDs>(),
      mapper: getIt<UserMapper>(),
    ),
  );

  // usecases
  getIt.registerFactory(() => SignInEmailUc(getIt<AuthRepository>()));
  getIt.registerFactory(() => SignOutUc(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterUc(getIt<AuthRepository>()));
  getIt.registerFactory(() => AuthStateStreamUc(getIt<AuthRepository>()));
}
