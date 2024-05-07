import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/employees/data/models/get_employee_request.model.dart';
import 'package:kiosk/src/feature/employees/data/repositories/employee.repository.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:equatable/equatable.dart';

class GetEmployeeUsecase implements UseCase<List<Employee>, Params> {
  final EmployeeRepositoryImpl repository;

  GetEmployeeUsecase(this.repository);

  @override
  Future<Either<Failure, List<Employee>>> call(Params params) async =>
      await repository.getEmployee(params.baseUrl, params.request);
}

class Params extends Equatable {
  final String baseUrl;
  final GetEmployeeRequest request;

  const Params({required this.baseUrl, required this.request});

  @override
  List<Object> get props => [request.authToken];
}
