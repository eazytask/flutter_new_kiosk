import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_request.model.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_response.model.dart';
import 'package:kiosk/src/feature/employees/data/models/get_employee_request.model.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';

abstract class IEmployeeRepository {
  Future<Either<Failure, List<Employee>>> getEmployee(
      String baseUrl, GetEmployeeRequest request);
  Future<Either<Failure, List<Project>>> getProject(
      String baseUrl, CommonGetRequest request);
  Future<Either<Failure, Shift?>> checkPin(
      String baseUrl, CheckPinRequest request);
}
