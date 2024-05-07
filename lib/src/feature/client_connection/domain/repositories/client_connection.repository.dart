import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/client_connection/domain/entities/db_connection.entity.dart';

abstract class ClientConnectionRepository {


  Future<bool> removeClientConnection();
  Future<bool> removeClientBaseUrl();

  Future<Either<Failure, bool>> saveClientConnection(ClientConnection connection);
  Future<bool> saveClientBaseUrl(String baseUrl);

  ClientConnection? fetchClientConnection();
  String? fetchClientBaseUrl();
}
