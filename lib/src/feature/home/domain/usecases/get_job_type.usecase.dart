import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/home/data/repositories/home.repository.dart';
import 'package:equatable/equatable.dart';

class GetJobTypeUsecase implements UseCase<List<JobType>, Params> {
  final HomeRepositoryImpl repository;

  GetJobTypeUsecase(this.repository);

  @override
  Future<Either<Failure, List<JobType>>> call(Params params) async =>
      await repository.getJobTypes(params.baseUrl, params.request);
}

class Params extends Equatable {
  final String baseUrl;
  final CommonGetRequest request;

  const Params({required this.baseUrl, required this.request});

  @override
  List<Object> get props => [request.authToken];
}
