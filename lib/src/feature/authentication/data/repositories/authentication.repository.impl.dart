
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/error/exception.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/authentication/data/datasources/local/authentication_local.datasource.dart';
import 'package:kiosk/src/core/error/logger.dart' show setCrashlyticsUserIdentifier;
import 'package:kiosk/src/feature/authentication/data/datasources/remote/authentication_remote.datasource.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/domain/entities/authentication.entity.dart';
import 'package:kiosk/src/feature/authentication/domain/repositories/authentication.repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  // final NetworkInfo networkInfo;
  final AuthenticationRemoteDataSource remoteDataSource;
  final AuthenticationLocalDataSource localDataSource;

  AuthenticationRepositoryImpl({
    // required this.networkInfo,
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Authentication>> login(String baseUrl, AuthRequest authRequest) async {
    // if (await networkInfo.isConnected == false) {
    //   return Left(NetworkFailure("Having trouble of connecting to internet"));
    // }
    try {
      var result = await remoteDataSource.login(baseUrl, authRequest);
      if (result.user.token != null) saveAccessToken(result.user.token!);
      setCrashlyticsUserIdentifier(result.user.id.toString());
      return Right(result);
    } on RequestException catch (e) {
      return Left(AppFailure(e.message));
    } on ServerException {
      return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
    } on InternetConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutConnectionException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on AccountDeactivatedException catch (e) {
      return Left(AccountDeactivatedFailure(e.message));
    } on UnAuthorizedException catch (e) {
      return Left(UnAuthorizedFailure(e.message));
    } on FailureException catch (e) {
      return Left(AppFailure(e.message));
    } catch (e) {
      return const Left(AppFailure("Login failed, please try again!"));
    }
    
  }

  @override
  Future<Either<Failure, bool>> logoutApi(String baseUrl, String? authToken) async {

    try {
      var result = await remoteDataSource.logout(baseUrl, authToken);
      return Right(result);
    } on RequestException catch (e) {
      return Left(AppFailure(e.message));
    } on ServerException {
      return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
    } on InternetConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutConnectionException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on UnAuthorizedException catch (e) {
      return Left(UnAuthorizedFailure(e.message));
    } on FailureException catch (e) {
      return Left(AppFailure("Something went wrong! ${e.message}"));
    } catch (e) {
      return const Left(AppFailure("Login failed, please try again!"));
    }

  }
  //
  // @override
  // Future<Either<Failure, bool>> removeFcmTokenApi(String baseUrl, String? authToken) async {
  //   // if (await networkInfo.isConnected == false) {
  //   //   return Left(NetworkFailure("Having trouble of connecting to internet"));
  //   // }
  //   try {
  //     var result = await remoteDataSource.removeFcmTokenApi(baseUrl, fetchFcmToken(), authToken);
  //     return Right(result);
  //   } on RequestException catch (e) {
  //     return Left(AppFailure(e.message));
  //   } on ServerException {
  //     return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
  //   } on InternetConnectionException catch (e) {
  //     return Left(ConnectionFailure(e.message));
  //   } on TimeoutConnectionException catch (e) {
  //     return Left(TimeoutFailure(e.message));
  //   } on UnAuthorizedException catch (e) {
  //     return Left(UnAuthorizedFailure(e.message));
  //   } on FailureException catch (e) {
  //     return Left(AppFailure("Something went wrong! ${e.message}"));
  //   } catch (e) {
  //     return const Left(AppFailure("Login failed, please try again!"));
  //   }
  //
  // }
  //
  // Future<Either<Failure, bool>> submitFcmToken(String baseUrl, String? token, String? authToken) async {
  //   try {
  //     var result = await remoteDataSource.submitFcmToken(baseUrl, token, authToken);
  //     return Right(result);
  //   } on RequestException catch (e) {
  //     return Left(AppFailure(e.message));
  //   } on ServerException {
  //     return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
  //   } on InternetConnectionException catch (e) {
  //     return Left(ConnectionFailure(e.message));
  //   } on TimeoutConnectionException catch (e) {
  //     return Left(TimeoutFailure(e.message));
  //   } on UnAuthorizedException catch (e) {
  //     return Left(UnAuthorizedFailure(e.message));
  //   } on FailureException catch (e) {
  //     return Left(AppFailure("Something went wrong! ${e.message}"));
  //   } catch (e) {
  //     return const Left(AppFailure("Login failed, please try again!"));
  //   }
  // }
  //
  // @override
  // Future<Either<Failure, User>> verifyCodeAndActivate(VerifyActivationRequest request) async {
  //   // if (await networkInfo.isConnected == false) {
  //   //   return Left(NetworkFailure("Having trouble of connecting to internet"));
  //   // }
  //   try {
  //     return Right(await remoteDataSource.postVerifyCode(request));
  //   } on RequestException catch (e) {
  //     return Left(AppFailure(e.message));
  //   } on ServerException {
  //     return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
  //   } on InternetConnectionException catch (e) {
  //     return Left(ConnectionFailure(e.message));
  //   } on TimeoutConnectionException catch (e) {
  //     return Left(TimeoutFailure(e.message));
  //   } on FailureException catch (e) {
  //     return Left(AppFailure(e.message));
  //   } catch (e) {
  //     return const Left(AppFailure(AppStrings.appUnrecognisedError));
  //   }
  // }
  //
  @override
  Future<bool> logout() async {
    return await removeAccessToken() && await removeRefreshToken() && await removeUser()
        && await removeFcmToken();
  }



  @override
  String? fetchFcmToken() {
    return localDataSource.fetchFcmToken();
  }



  @override
  Future<bool> removeAccessToken() {
    return localDataSource.removeAccessToken();
  }

  @override
  Future<bool> removeFcmToken() {
    return localDataSource.removeFcmToken();
  }

  @override
  Future<bool> removeRefreshToken() {
    return localDataSource.removeRefreshToken();
  }

  @override
  Future<bool> saveAccessToken(String token) {
    return localDataSource.saveAccessToken(token);
  }

  @override
  Future<bool> saveFcmToken(String? token) {
    return localDataSource.saveFcmToken(token);
  }

  @override
  Future<bool> saveRefreshToken(String token) {
    return localDataSource.saveRefreshToken(token);
  }

  @override
  Future<String> fetchUser() {
    return localDataSource.fetchUser();
  }

  @override
  Future<bool> saveUser(String userEncoded) {
    return localDataSource.saveUser(userEncoded);
  }

  @override
  Future<bool> removeUser() {
    return localDataSource.removeUser();
  }

  @override
  void saveShowLaterUpdateDialog() {
    localDataSource.saveShowLaterUpdate();
  }

  @override
  bool fetchShowLaterUpdateDialog() {
    return localDataSource.fetchShowLaterUpdate();
  }

  @override
  Future<bool> removeShowLaterUpdateDialog() async {
    return await localDataSource.removeShowLaterUpdate();
  }

  @override
  String? fetchAccessToken(int userId) {
    return localDataSource.fetchAccessToken(userId);
  }
}
