
import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/client_connection/domain/entities/db_connection.entity.dart';
import 'package:kiosk/src/feature/client_connection/domain/repositories/client_connection.repository.dart';

class HandleClientConfigUsecase implements UseCase<bool, Params> {
  final ClientConnectionRepository repository;

  HandleClientConfigUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return repository.saveClientConnection(params.connection);
  }

  void saveClientBaseUrl(String baseUrl) {
    repository.saveClientBaseUrl(baseUrl);
  }

  ClientConnection? fetchClientConnection() {
    return repository.fetchClientConnection();
  }

  String? fetchClientBaseUrl() {
    return repository.fetchClientBaseUrl();
  }

}

class Params {
  final ClientConnection connection;

  Params(this.connection);
}