import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/home/data/models/sign_in_out_request.model.dart';
import 'package:kiosk/src/feature/home/data/repositories/home.repository.dart';
import 'package:equatable/equatable.dart';

class SignInAndOutUsecase implements UseCase<bool, Params> {
  final HomeRepositoryImpl repository;

  SignInAndOutUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async =>
      await repository.signInAndOut(params.baseUrl, params.path, params.request);
}

class Params extends Equatable {
  final String baseUrl;
  final String path;
  final SignInAndOutRequest request;

  const Params({
    required this.baseUrl,
    required this.path,
    required this.request,
  });

  @override
  List<Object> get props => [request.authToken];
}
