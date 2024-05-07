import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/home/data/models/sign_in_out_request.model.dart';
import 'package:kiosk/src/feature/home/data/models/start_unscheduled_shift_request.model.dart';

abstract class IHomeRepository {
  Future<Either<Failure, List<JobType>>> getJobTypes(
      String baseUrl, CommonGetRequest request);

  Future<Either<Failure, Shift?>> startUnscheduledShift(
      String baseUrl, StartUnscheduledShiftRequest request);

  Future<Either<Failure, bool>> signInAndOut(
      String baseUrl, String path, SignInAndOutRequest request);
}
