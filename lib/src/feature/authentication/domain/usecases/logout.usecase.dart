import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/authentication/domain/repositories/authentication.repository.dart';

class LogoutUsecase {
  final AuthenticationRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<Failure, bool>> call(String baseUrl, String? authToken) async {
    await repository.logoutApi(baseUrl, authToken);
    return Right(await repository.logout());
  }


}