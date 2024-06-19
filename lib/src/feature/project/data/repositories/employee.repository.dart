import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/error/exception.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/feature/employees/data/datasources/employee.datasource.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_request.model.dart';
import 'package:kiosk/src/feature/employees/data/models/get_employee_request.model.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/feature/employees/domain/repositories/iemployee.repository.dart';

class EmployeeRepositoryImpl extends IEmployeeRepository {

  final EmployeeRemoteDataSourceImpl dataSource;

  EmployeeRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, List<Employee>>> getEmployee(
      String baseUrl, GetEmployeeRequest request) async {
    try {
      return Right(await dataSource.getEmployee(baseUrl, request));
    } on UnAuthorizedException catch (e) {
      return Left(UnAuthorizedFailure(e.message));
    } on ServerException {
      return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
    } on RequestException catch (e) {
      return Left(AppFailure(e.message));
    } on InternetConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutConnectionException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      cPrint(e.toString());
      return const Left(AppFailure(AppStrings.appUnrecognisedError));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProject(
      String baseUrl, CommonGetRequest request) async {
    try {
      return Right(await dataSource.getProject(baseUrl, request));
    } on UnAuthorizedException catch (e) {
      return Left(UnAuthorizedFailure(e.message));
    } on ServerException {
      return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
    } on RequestException catch (e) {
      return Left(AppFailure(e.message));
    } on InternetConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutConnectionException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      cPrint(e.toString());
      return const Left(AppFailure(AppStrings.appUnrecognisedError));
    }
  }

  @override
  Future<Either<Failure, Shift?>> checkPin(String baseUrl, CheckPinRequest request) async {
    try {
      return Right(await dataSource.checkPin(baseUrl, request));
    } on UnAuthorizedException catch (e) {
      return Left(UnAuthorizedFailure(e.message));
    } on ServerException {
      return const Left(ServerFailure(AppStrings.serverUnrecognisedError));
    } on RequestException catch (e) {
      return Left(AppFailure(e.message));
    } on InternetConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on TimeoutConnectionException catch (e) {
      return Left(TimeoutFailure(e.message));
    } catch (e) {
      cPrint(e.toString());
      return const Left(AppFailure(AppStrings.appUnrecognisedError));
    }
  }
}
