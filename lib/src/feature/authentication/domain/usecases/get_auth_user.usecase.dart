import 'dart:convert';

import 'package:kiosk/src/core/domain/entities/user.entity.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/domain/entities/authentication.entity.dart';
import 'package:kiosk/src/feature/authentication/domain/repositories/authentication.repository.dart';


class GetAuthUserUsecase {
  final AuthenticationRepository repository;

  GetAuthUserUsecase(this.repository);

  String? call() {
    return repository.fetchAccessToken(1);
  }

  Future<bool> saveAccessToken(String token) async => await repository.saveAccessToken(token);
  Future<bool> saveRefreshToken(String token) async => await repository.saveRefreshToken(token);

  Future<bool> saveUser(User user) async {
    String userEncoded = jsonEncode(user.toMap());
    return await repository.saveUser(userEncoded);
  }

  Future<User> fetchUser() async {
    var userEncoded = await repository.fetchUser();
    return User.fromJson(jsonDecode(userEncoded));
  }

  Future<bool> removeUser() async {
    var userEncoded = await repository.removeUser();
    return userEncoded;
  }

  Future<void> removePrefs() async {
    await repository.removeAccessToken();
    await repository.removeRefreshToken();
    await repository.removeFcmToken();
  }

  Future<bool> saveDataToPrefs(AuthRequest request, User user) async {
    if (user.token == null) return false;
    bool aResult = await repository.saveAccessToken(user.token!);

    return aResult;
  }

  // Future<Token?> generateAndSaveTokens(String userId, String refreshToken) async {
  //   try {
  //     Token? result = await repository.refresh(userId, refreshToken);
  //     if (result != null && result.access!.isNotEmpty) {
  //       await saveAccessToken(result.access!);
  //     }
  //     if (result != null && result.refresh!.isNotEmpty) {
  //       await saveRefreshToken(result.refresh!);
  //     }
  //     return result;
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  void saveShowLaterUpdateDialog() {
    repository.saveShowLaterUpdateDialog();
  }

  bool isShowLaterUpdateDialog() {
    return repository.fetchShowLaterUpdateDialog();
  }

  Future<bool> setShowUpdateDialog() async {
    return await repository.removeShowLaterUpdateDialog();
  }
}
//
// class Params extends Equatable {
//   final int userId;
//
//   Params({required this.userId});
//
//   @override
//   List<Object> get props => [userId];
// }