
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/core/presentation/snack_bars/custom.snackbar.dart';
import 'package:kiosk/src/core/provider/base.provider.dart';
import 'package:kiosk/src/feature/client_connection/domain/entities/db_connection.entity.dart';
import 'package:kiosk/src/feature/client_connection/domain/usecases/save_client_config.usecase.dart';
import 'package:kiosk/src/injection_container.dart';
import 'package:flutter/material.dart';

class ClientConnectionProvider extends BaseProvider {


  final HandleClientConfigUsecase _manageClientConfigUsecase = sl<HandleClientConfigUsecase>();

  String? _baseUrl;
  String get baseUrl => _baseUrl ?? urlHost;
  set baseUrl(String value) {
    _baseUrl = value;
    cPrint(_baseUrl);
  }

  ClientConnection? _selectedClientConnection;
  ClientConnection? get selectedClientConnection => _selectedClientConnection;
  set selectedClientConnection(ClientConnection? connection) {
    _selectedClientConnection = connection;
    notifyListeners();
  }


  void changeBaseUrl(context, String text) {
    _baseUrl = text;
    _manageClientConfigUsecase.saveClientBaseUrl(text);
    customSnackBar(context, "Base URL changed to $_baseUrl", backgroundColor: Colors.green);
  }

  String? fetchClientBaseUrl() {
    return _manageClientConfigUsecase.fetchClientBaseUrl();
  }

  ClientConnection? fetchClientConnection() {
    return _manageClientConfigUsecase.fetchClientConnection();
  }

}