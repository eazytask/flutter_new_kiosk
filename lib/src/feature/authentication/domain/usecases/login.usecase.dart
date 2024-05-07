import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/domain/entities/authentication.entity.dart';
import 'package:kiosk/src/feature/authentication/domain/repositories/authentication.repository.dart';
import 'package:equatable/equatable.dart';

class LoginUsecase implements UseCase<Authentication, Params>{
  final AuthenticationRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, Authentication>> call(Params params) async {
    return await repository.login(params.baseUrl, params.authRequest);
  }

}

class Params extends Equatable {
  final String baseUrl;
  final AuthRequest authRequest;
  const Params({required this.baseUrl, required this.authRequest});

  @override
  List<Object> get props => [authRequest.email, authRequest.password];
}