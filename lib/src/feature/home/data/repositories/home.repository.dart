import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/core/error/exception.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/feature/home/data/datasources/home.datasource.dart';
import 'package:kiosk/src/feature/home/data/models/sign_in_out_request.model.dart';
import 'package:kiosk/src/feature/home/data/models/start_unscheduled_shift_request.model.dart';
import 'package:kiosk/src/feature/home/domain/repositories/ihome.repository.dart';

class HomeRepositoryImpl extends IHomeRepository {
  final HomeRemoteDataSourceImpl dataSource;

  HomeRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, List<JobType>>> getJobTypes(
      String baseUrl, CommonGetRequest request) async {
    try {
      return Right(await dataSource.getJobTypes(baseUrl, request));
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
  Future<Either<Failure, Shift?>> startUnscheduledShift(
      String baseUrl, StartUnscheduledShiftRequest request) async {
    try {
      return Right(await dataSource.startUnscheduledShift(baseUrl, request));
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
  Future<Either<Failure, bool>> signInAndOut(
      String baseUrl, String path, SignInAndOutRequest request) async {
    try {
      return Right(await dataSource.signInAndOut(baseUrl, path, request));
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
