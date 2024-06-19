import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/feature/employees/data/repositories/employee.repository.dart';
import 'package:equatable/equatable.dart';

class GetProjectUsecase implements UseCase<List<Project>, Params> {
  final EmployeeRepositoryImpl repository;

  GetProjectUsecase(this.repository);

  @override
  Future<Either<Failure, List<Project>>> call(Params params) async =>
      await repository.getProject(params.baseUrl, params.request);
}

class Params extends Equatable {
  final String baseUrl;
  final CommonGetRequest request;

  const Params({required this.baseUrl, required this.request});

  @override
  List<Object> get props => [request.authToken];
}
