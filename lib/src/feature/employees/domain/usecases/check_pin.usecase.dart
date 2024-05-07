import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_request.model.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_response.model.dart';
import 'package:kiosk/src/feature/employees/data/repositories/employee.repository.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:equatable/equatable.dart';

class CheckPinUsecase implements UseCase<Shift?, Params> {
  final EmployeeRepositoryImpl repository;

  CheckPinUsecase(this.repository);

  @override
  Future<Either<Failure, Shift?>> call(Params params) async =>
      await repository.checkPin(params.baseUrl, params.request);
}

class Params extends Equatable {
  final String baseUrl;
  final CheckPinRequest request;

  const Params({required this.baseUrl, required this.request});

  @override
  List<Object> get props => [request.authToken];
}