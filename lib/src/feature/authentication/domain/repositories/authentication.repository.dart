import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/domain/entities/authentication.entity.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, Authentication>> login(String baseUrl, AuthRequest authRequest);
  Future<bool> logout();
  Future<Either<Failure, bool>> logoutApi(String baseUrl, String? authToken);
  // Future<Either<Failure, bool>> removeFcmTokenApi(String baseUrl, String? authToken);
  // Future<Either<Failure, bool>> submitFcmToken(String baseUrl, String? token, String? authToken);
  // Future<Either<Failure, User>> verifyCodeAndActivate(VerifyActivationRequest request);

  Future<bool> removeAccessToken();
  Future<bool> removeRefreshToken();
  Future<bool> removeFcmToken();
  Future<bool> removeUser();

  Future<bool> saveAccessToken(String token);
  Future<bool> saveRefreshToken(String token);
  Future<bool> saveUser(String userEncoded);
  Future<bool> saveFcmToken(String? token);

  String? fetchAccessToken(int userId);
  Future<String> fetchUser();
  String? fetchFcmToken();

  void saveShowLaterUpdateDialog();
  bool fetchShowLaterUpdateDialog();
  Future<bool> removeShowLaterUpdateDialog();
}
