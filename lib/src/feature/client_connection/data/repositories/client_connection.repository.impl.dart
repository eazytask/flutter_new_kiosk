
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/client_connection/data/datasources/local/client_connection_local.datasource.dart';
import 'package:kiosk/src/feature/client_connection/domain/entities/db_connection.entity.dart';
import 'package:kiosk/src/feature/client_connection/domain/repositories/client_connection.repository.dart';

class ClientConnectionRepositoryImpl implements ClientConnectionRepository {

  final ClientConnectionLocalDataSource localDataSource;

  ClientConnectionRepositoryImpl({
    required this.localDataSource,
  });


  @override
  ClientConnection? fetchClientConnection() {
    return localDataSource.fetchClientConnection();
  }

  @override
  Future<bool> removeClientConnection() {
    return localDataSource.removeClientConnection();
  }

  @override
  Future<Either<Failure, bool>> saveClientConnection(ClientConnection connection) {
    return localDataSource.saveClientConnection(connection);
  }

  @override
  Future<bool> saveClientBaseUrl(String baseUrl) {
    return localDataSource.saveBaseUrl(baseUrl);
  }

  @override
  String? fetchClientBaseUrl() {
    return localDataSource.fetchBaseUrl();
  }

  @override
  Future<bool> removeClientBaseUrl() {
    return localDataSource.removeBaseUrl();
  }


}
