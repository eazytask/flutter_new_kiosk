import 'package:dartz/dartz.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/feature/home/presentation/screens/home.screen.dart';
import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/error/failures.dart';
import 'package:kiosk/src/core/presentation/snack_bars/custom.snackbar.dart';
import 'package:kiosk/src/core/provider/base.provider.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_request.model.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_response.model.dart';
import 'package:kiosk/src/feature/employees/data/models/get_employee_request.model.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/feature/employees/domain/usecases/check_pin.usecase.dart'
    as cp;
import 'package:kiosk/src/feature/employees/domain/usecases/get_employee.usecase.dart';
import 'package:kiosk/src/feature/employees/domain/usecases/get_project.usecase.dart'
    as gp;
import 'package:kiosk/src/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeProvider extends BaseProvider {
  final GetEmployeeUsecase _employeeUsecase = sl<GetEmployeeUsecase>();
  final gp.GetProjectUsecase _projectUsecase = sl<gp.GetProjectUsecase>();
  final cp.CheckPinUsecase _checkPinUsecase = sl<cp.CheckPinUsecase>();
  List<Employee> _employees = [];
  List<Project> _projects = [];
  Shift? _shift;

  List<Employee> get employees => _employees;

  List<Project> get projects => _projects;

  Shift? get shift => _shift;

  Future<void> fetchEmployee(
      context, String baseUrl, GetEmployeeRequest request) async {
    // setState(ViewState.Busy);
    loading = true;

    Either<Failure, List<Employee>> results =
        await _employeeUsecase(Params(baseUrl: baseUrl, request: request));

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
      (List<Employee> employees) {
        _employees.clear();
        _employees = employees;
        loading = false;
      },
    );
  }

  Future<void> fetchProject(
      context, String baseUrl, CommonGetRequest request) async {
    loading = true;

    Either<Failure, List<Project>> results =
        await _projectUsecase(gp.Params(baseUrl: baseUrl, request: request));

    results.fold(
      (failure) {
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
      (List<Project> projects) {
        _projects.clear();
        _projects = projects;
        loading = false;
      },
    );
  }

  Future<void> checkPin(context, String baseUrl, CheckPinRequest request,
      Employee employee, int projectId, String projectName) async {
    // setState(ViewState.Busy);
    // isBusy = true;

    Either<Failure, Shift?> results =
        await _checkPinUsecase(cp.Params(baseUrl: baseUrl, request: request));

    results.fold(
      (failure) {
        // setState(ViewState.Error);
        loading = false;
        customSnackBar(context, failure.message);
      },
      (Shift? shift) {
        _shift = shift;
        loading = false;
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteConstants.homeScreen,
          arguments: HomeScreen(
            employee: employee,
            shift: shift,
            projectId: projectId,
            projectName: projectName,
          ),
          (route) => false,
        );
      },
    );
  }
}
