import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/core/domain/usecases/usecase.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/feature/home/data/models/start_unscheduled_shift_request.model.dart';
import 'package:kiosk/src/feature/home/data/repositories/home.repository.dart';
import 'package:equatable/equatable.dart';

class StartUnscheduledShiftUsecase implements UseCase<Shift?, Params> {
  final HomeRepositoryImpl repository;

  StartUnscheduledShiftUsecase(this.repository);

  @override
  Future<Either<Failure, Shift?>> call(Params params) async =>
      await repository.startUnscheduledShift(params.baseUrl, params.request);
}

class Params extends Equatable {
  final String baseUrl;
  final StartUnscheduledShiftRequest request;

  const Params({required this.baseUrl, required this.request});

  @override
  List<Object> get props => [request.authToken];
}