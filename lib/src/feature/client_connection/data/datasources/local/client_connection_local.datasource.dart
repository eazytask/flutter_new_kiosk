import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/constants/pref_keys.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/feature/client_connection/domain/entities/db_connection.entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ClientConnectionLocalDataSource {
  Future<bool> removeClientConnection();
  Future<bool> removeBaseUrl();

  Future<Either<Failure, bool>> saveClientConnection(ClientConnection connection);
  Future<bool> saveBaseUrl(String url);

  ClientConnection? fetchClientConnection();
  String? fetchBaseUrl();

}

class ClientConnectionLocalDataSourceImpl implements ClientConnectionLocalDataSource {
  final SharedPreferences prefs;

  ClientConnectionLocalDataSourceImpl(this.prefs);

  @override
  ClientConnection? fetchClientConnection() {
    String? con = prefs.getString(PrefConstants.clientConnectionKey);
    if (con == null || con == "") return null;
    var decoded = json.decode(con);
    return ClientConnection(
      id: decoded["id"],
      name: decoded["username"],
      key: decoded["key"],
    );
  }

  @override
  String? fetchBaseUrl() {
    var url = prefs.getString(PrefConstants.clientBaseUrlKey);
    return url;
  }

  @override
  Future<bool> removeClientConnection() async {
    return await prefs.remove(PrefConstants.clientConnectionKey);
  }

  @override
  Future<bool> removeBaseUrl() async {
    return await prefs.remove(PrefConstants.clientBaseUrlKey);
  }

  @override
  Future<Either<Failure, bool>> saveClientConnection(ClientConnection? connection) async {
    cPrint("[saveClientConnection] Saved connection.");
    try {
      return Right(await prefs.setString(PrefConstants.clientConnectionKey, json.encode(connection)));
    } on Exception catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  @override
  Future<bool> saveBaseUrl(String token) async {
    cPrint("[saveBaseUrl] Saved base url.");
    return await prefs.setString(PrefConstants.clientBaseUrlKey, token);
  }
}