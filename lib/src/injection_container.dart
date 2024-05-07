
import 'package:kiosk/src/core/data/datasources/local/device_info.datasource.dart';
import 'package:kiosk/src/core/data/datasources/local/storage.helper.dart';
import 'package:kiosk/src/core/provider/remote_config.provider.dart';
import 'package:kiosk/src/core/provider/theme.provider.dart';
import 'package:kiosk/src/feature/authentication/data/datasources/local/authentication_local.datasource.dart';
import 'package:kiosk/src/feature/authentication/data/datasources/remote/authentication_remote.datasource.dart';
import 'package:kiosk/src/feature/authentication/data/repositories/authentication.repository.impl.dart';
import 'package:kiosk/src/feature/authentication/domain/repositories/authentication.repository.dart';
import 'package:kiosk/src/feature/authentication/domain/usecases/get_auth_user.usecase.dart';
import 'package:kiosk/src/feature/authentication/domain/usecases/login.usecase.dart';
import 'package:kiosk/src/feature/authentication/domain/usecases/logout.usecase.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/client_connection/data/datasources/local/client_connection_local.datasource.dart';
import 'package:kiosk/src/feature/client_connection/data/repositories/client_connection.repository.impl.dart';
import 'package:kiosk/src/feature/client_connection/domain/repositories/client_connection.repository.dart';
import 'package:kiosk/src/feature/client_connection/domain/usecases/save_client_config.usecase.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:kiosk/src/feature/employees/data/datasources/employee.datasource.dart';
import 'package:kiosk/src/feature/employees/data/repositories/employee.repository.dart';
import 'package:kiosk/src/feature/employees/domain/usecases/check_pin.usecase.dart';
import 'package:kiosk/src/feature/employees/domain/usecases/get_employee.usecase.dart';
import 'package:kiosk/src/feature/employees/domain/usecases/get_project.usecase.dart';
import 'package:kiosk/src/feature/employees/presentation/providers/employee.provider.dart';
import 'package:kiosk/src/feature/home/data/datasources/home.datasource.dart';
import 'package:kiosk/src/feature/home/data/repositories/home.repository.dart';
import 'package:kiosk/src/feature/home/domain/usecases/get_job_type.usecase.dart';
import 'package:kiosk/src/feature/home/domain/usecases/sign_in_out.usecase.dart';
import 'package:kiosk/src/feature/home/domain/usecases/start_unscheduled_shift.usecase.dart';
import 'package:kiosk/src/feature/home/presentation/providers/home.provider.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  //! External
  sl.registerLazySingleton(() => http.Client());

  // Device specific datasources
  sl.registerLazySingleton(() => StorageHelper());

  // Device specific Providers
  sl.registerLazySingleton(() => ThemeProvider(cacheManager: sl()));

  // Feature - API required device details generation
  sl.registerLazySingleton(() => DeviceInfo());

  // Feature - Push Notification
  // Provider
  sl.registerLazySingleton(() => RemoteConfigProvider());

  //! Features - client connection
  // Provider
  sl.registerLazySingleton(() => ClientConnectionProvider());

  // Use Case
   sl.registerLazySingleton(() => HandleClientConfigUsecase(sl()));

  // Repository
  sl.registerLazySingleton<ClientConnectionRepository>(() =>
      ClientConnectionRepositoryImpl(localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<ClientConnectionLocalDataSource>(
      () => ClientConnectionLocalDataSourceImpl(sl()));

  //! Features - authentication
  // Provider
  sl.registerLazySingleton(() => AuthProvider());

  // Use Case
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => GetAuthUserUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthenticationRepository>(
      () => AuthenticationRepositoryImpl(
            /* /* networkInfo: sl(), */ */
            remoteDataSource: sl(),
            localDataSource: sl(),
          ));

  // Data sources
  sl.registerLazySingleton<AuthenticationRemoteDataSource>(
      () => AuthenticationRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthenticationLocalDataSource>(
      () => AuthenticationLocalDataSourceImpl(sl()));

  //! Features - employee
  // Provider
  sl.registerLazySingleton(() => EmployeeProvider());
  // Use Case
  sl.registerLazySingleton(() => GetEmployeeUsecase(sl()));
  sl.registerLazySingleton(() => GetProjectUsecase(sl()));
  sl.registerLazySingleton(() => CheckPinUsecase(sl()));
  // Repository
  sl.registerLazySingleton<EmployeeRepositoryImpl>(() => EmployeeRepositoryImpl(
    /* /* networkInfo: sl(), */ */
      dataSource: sl()));
  // Data sources
  sl.registerLazySingleton<EmployeeRemoteDataSourceImpl>(
          () => EmployeeRemoteDataSourceImpl(sl()));


  //! Features - employee
  // Provider
  sl.registerLazySingleton(() => HomeProvider());
  // Use Case
  sl.registerLazySingleton(() => GetJobTypeUsecase(sl()));
  sl.registerLazySingleton(() => StartUnscheduledShiftUsecase(sl()));
  sl.registerLazySingleton(() => SignInAndOutUsecase(sl()));
  // Repository
  sl.registerLazySingleton<HomeRepositoryImpl>(() => HomeRepositoryImpl(
    /* /* networkInfo: sl(), */ */
      dataSource: sl()));
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSourceImpl>(
          () => HomeRemoteDataSourceImpl(sl()));


}
