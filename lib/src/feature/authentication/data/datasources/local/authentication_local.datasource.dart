import 'package:kiosk/src/core/constants/pref_keys.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthenticationLocalDataSource {
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
  String fetchFcmToken();

  Future<bool> removeShowLaterUpdate();
  Future<bool> saveShowLaterUpdate();
  bool fetchShowLaterUpdate();
}

class AuthenticationLocalDataSourceImpl implements AuthenticationLocalDataSource {
  final SharedPreferences prefs;

  AuthenticationLocalDataSourceImpl(this.prefs);


  @override
  Future<bool> removeAccessToken() async {
    return await prefs.remove(PrefConstants.accessKey);
  }

  @override
  Future<bool> removeFcmToken() async {
    return await prefs.remove(PrefConstants.fcmKey);
  }

  @override
  Future<bool> removeRefreshToken() async {
    return await prefs.remove(PrefConstants.refreshKey);
  }

  @override
  Future<bool> saveAccessToken(String token) async {
    cPrint("[saveAccessToken] Saved Authorization.");
    return await prefs.setString(PrefConstants.accessKey, token);
  }

  @override
  Future<bool> saveRefreshToken(String token) async {
    cPrint("[saveRefreshToken] Saved Auth-Refresh.");
    return await prefs.setString(PrefConstants.refreshKey, token);
  }

  @override
  Future<String> fetchUser() async {
    var user = prefs.getString(PrefConstants.authUserKey) ?? "{}";
    return user;
  }

  @override
  Future<bool> saveUser(String userEncoded) async {
    cPrint("[saveUser] Saved Auth-User.");
    return await prefs.setString(PrefConstants.authUserKey, userEncoded);
  }

  @override
  Future<bool> removeUser() async {
    return await prefs.remove(PrefConstants.authUserKey);
  }

  @override
  String fetchFcmToken() {
    String token = prefs.getString(PrefConstants.fcmKey) ?? "{}";
    return token;
  }

  @override
  Future<bool> saveFcmToken(String? token) async {
    cPrint("[saveFcmToken] Saved FCM token.");
    return await prefs.setString(PrefConstants.fcmKey, token ?? "");
  }

  @override
  bool fetchShowLaterUpdate() {
    var isLater = prefs.getString(PrefConstants.showUpdateLaterKey)
        ?? DateTime.now().subtract(Duration(days: 3)).toString();
    cPrint("[fetchShowLaterUpdate] $isLater.");
    return DateTime.now().difference(DateTime.parse(isLater)).inDays > 2;
  }

  @override
  Future<bool> removeShowLaterUpdate() async {
    cPrint("[removeShowLaterUpdate] removed.");
    return await prefs.remove(PrefConstants.showUpdateLaterKey);
  }

  @override
  Future<bool> saveShowLaterUpdate() async {
    cPrint("[saveShowLaterUpdate] Saved show later.");
    return await prefs.setString(PrefConstants.showUpdateLaterKey, DateTime.now().toString());
  }

  @override
  String? fetchAccessToken(int userId) {
    var token = prefs.getString(PrefConstants.accessKey);
    return token;
  }
}