import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/core/presentation/snack_bars/custom.snackbar.dart';
import 'package:kiosk/src/core/provider/base.provider.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/home/data/models/sign_in_out_request.model.dart';
import 'package:kiosk/src/feature/home/data/models/start_unscheduled_shift_request.model.dart';
import 'package:kiosk/src/feature/home/domain/usecases/get_job_type.usecase.dart';
import 'package:kiosk/src/feature/home/domain/usecases/sign_in_out.usecase.dart'
    as s_i_o;
import 'package:kiosk/src/feature/home/domain/usecases/start_unscheduled_shift.usecase.dart'
    as s_us_s;
import 'package:kiosk/src/injection_container.dart';
import 'package:flutter/material.dart';

class HomeProvider extends BaseProvider {
  final GetJobTypeUsecase _jobTypeUsecase = sl<GetJobTypeUsecase>();
  final s_i_o.SignInAndOutUsecase _signInAndOutUsecase =
      sl<s_i_o.SignInAndOutUsecase>();
  final s_us_s.StartUnscheduledShiftUsecase _startUnscheduledShiftUsecase =
      sl<s_us_s.StartUnscheduledShiftUsecase>();
  List<JobType> _jobTypes = [];
  Shift? _shift;

  List<JobType> get jobTypes => _jobTypes;

  Shift? get shift => _shift;

  Future<void> fetchJobType(
      context, String baseUrl, CommonGetRequest request) async {
    // setState(ViewState.Busy);
    loading = true;

    Either<Failure, List<JobType>> results =
        await _jobTypeUsecase(Params(baseUrl: baseUrl, request: request));

    results.fold(
      (failure) {
        // setState(ViewState.Error);
        loading = false;

        if (failure is UnAuthorizedFailure) {
          customSnackBar(context, failure.message,
              actionButton: SnackBarAction(
                label: AppStrings.loginBack,
                textColor: AppColors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  // Provider.of<AuthProvider>(context, listen: false)
                  //     .logout(baseUrl);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteConstants.loginScreen,
                    (route) => false,
                  );
                },
              ));
          return;
        }

        customSnackBar(context, failure.message);
      },
      (List<JobType> jobTypes) {
        _jobTypes = jobTypes;
        loading = false;
      },
    );
  }

  Future<void> startUnscheduledShift(
      context, String baseUrl, StartUnscheduledShiftRequest request) async {
    // setState(ViewState.Busy);
    loading = true;
    _shift = null;
    Either<Failure, Shift?> results = await _startUnscheduledShiftUsecase(
        s_us_s.Params(baseUrl: baseUrl, request: request));

    results.fold(
      (failure) {
        // setState(ViewState.Error);
        loading = false;

        if (failure is UnAuthorizedFailure) {
          customSnackBar(context, failure.message,
              actionButton: SnackBarAction(
                label: AppStrings.loginBack,
                textColor: AppColors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  // Provider.of<AuthProvider>(context, listen: false)
                  //     .logout(baseUrl);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteConstants.loginScreen,
                    (route) => false,
                  );
                },
              ));
          return;
        }

        customSnackBar(context, failure.message);
      },
      (Shift? shift) {
        _shift = shift;
        loading = false;
        customSnackBar(context, 'Unscheduled shift started successfully!',
            backgroundColor: AppColors.kNormalGreen);
      },
    );
  }

  Future<void> signInAndOut(context, String baseUrl, String path, String type,
      SignInAndOutRequest request) async {
    // setState(ViewState.Busy);
    // isBusy = true;

    Either<Failure, bool> results = await _signInAndOutUsecase(
        s_i_o.Params(baseUrl: baseUrl, path: path, request: request));

    results.fold(
      (failure) {
        // setState(ViewState.Error);
        loading = false;
        customSnackBar(context, failure.message);
      },
      (bool status) {
        loading = false;
        if (status) {
          customSnackBar(context, '$type Successfully',
              backgroundColor: AppColors.kNormalGreen);

          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteConstants.employeeScreen,
            (route) => false,
          );

          return status;
        } else {
          customSnackBar(context, AppStrings.appUnrecognisedError);
          return null;
        }
      },
    );
  }
}
