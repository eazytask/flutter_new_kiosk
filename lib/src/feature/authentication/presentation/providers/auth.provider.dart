

import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/domain/entities/user.entity.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/core/presentation/snack_bars/custom.snackbar.dart';
import 'package:kiosk/src/core/provider/base.provider.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/domain/usecases/get_auth_user.usecase.dart';
import 'package:kiosk/src/feature/authentication/domain/usecases/login.usecase.dart';
import 'package:kiosk/src/feature/authentication/domain/usecases/logout.usecase.dart';
import 'package:kiosk/src/injection_container.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class AuthProvider extends BaseProvider {
  LoginUsecase _loginUsecase = sl<LoginUsecase>();
LogoutUsecase _logoutUsecase = sl<LogoutUsecase>();
  GetAuthUserUsecase _authUserUsecase = sl<GetAuthUserUsecase>();
  // fcm.PostFcmTokenUsecase _fcmTokenUsecase = sl<fcm.PostFcmTokenUsecase>();

  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  User? user;
  String? authToken;


  Future<void> logout(BuildContext context, String baseUrl) async {
    if (isBusy) return;
    loading = true;

    var res = await _logoutUsecase(baseUrl, authToken);
    if (res.isRight()) {
      bool isRemoved = res.getOrElse(() => true);
      if (isRemoved) {
        user = null;
        authStatus = AuthStatus.NOT_LOGGED_IN;
        Navigator.of(context).pushNamedAndRemoveUntil(RouteConstants.loginScreen, (route) => false);
      }
    }
    loading = false;
    return;
  }

  /// Verify user's credentials for login
  Future<User?> signIn(String baseUrl, AuthRequest request, String routeName,
      BuildContext context) async {
    try {
      loading = true;
      var result =
          await _loginUsecase(Params(baseUrl: baseUrl, authRequest: request));

      return result.fold((l) {
        customSnackBar(context, l.message, backgroundColor: AppColors.kRed);
        user = null;
        loading = false;
        authStatus = AuthStatus.NOT_LOGGED_IN;


        return null;
      }, (r) {
        persistSuccessLogin(r.user);
        return user;
      });
    } catch (error) {
      loading = false;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      user = null;

      cPrint(error, errorIn: 'signIn');
      customSnackBar(context, AppStrings.appUnrecognisedError,
          backgroundColor: AppColors.kRed);
      return null;
    }
  }

  void persistSuccessLogin(User r) {
    authStatus = AuthStatus.LOGGED_IN;
    loading = false;
    user = r;

    if (r.token != null) {
      _authUserUsecase.saveAccessToken(r.token!);
      authToken = r.token!;
    }
    _authUserUsecase.saveUser(r);
  }

  /// Fetch current user profile
  Future<User?> getCurrentUser() async {
    isBusy = true;
    try {
      user ??= await _authUserUsecase.fetchUser();
      authToken = _authUserUsecase.call();
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
        isBusy = false;
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
        isBusy = false;
      }
      return user;
    } catch (error) {
      cPrint(error, errorIn: 'getCurrentUser');
      authStatus = AuthStatus.NOT_LOGGED_IN;
      isBusy = false;
      return null;
    }
  }

  bool get isUserLoggedIn {
    return user != null;
  }

  Future<void> forgetPassword(String email, BuildContext context) async {
    try {
      // await auth.sendPasswordResetEmail(email: email).then((value) {
      //   customSnackBar(scaffoldKey,
      //       'A reset password link is sent yo your mail.You can reset your password from there');
      //   logEvent('forgot+password');
      // }).catchError((error) {
      //   cprint(error.message);
      //   return false;
      // });
    } catch (error) {
      customSnackBar(context, error.toString());
      return Future.value(false);
    }
  }

  // void postFcmToken(String baseUrl, String? token, String? authToken) async {
  //   _fcmTokenUsecase(fcm.Params(baseUrl, token, authToken));
  // }
  //
  // void saveFcmToken(String? token) {
  //   _fcmTokenUsecase.saveFcmToken(token);
  // }



  Future<bool> removeUser() async {
    return await _authUserUsecase.removeUser();
  }

  void showUpdateDialogLater() {
    _authUserUsecase.saveShowLaterUpdateDialog();
  }

  void showUpdateDialog() {
    _authUserUsecase.setShowUpdateDialog();
  }

  bool isShowLaterUpdateDialog() {
    return _authUserUsecase.isShowLaterUpdateDialog();
  }

}
