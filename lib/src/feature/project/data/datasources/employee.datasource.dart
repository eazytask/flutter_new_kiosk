import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/data/models/response.model.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/error/exception.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/core/error/socket_exception_handle.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_request.model.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_response.model.dart';
import 'package:kiosk/src/feature/employees/data/models/get_employee_request.model.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:http/http.dart' as http;

abstract class IEmployeeRemoteDataSource {
  Future<List<Employee>> getEmployee(
      String baseUrl, GetEmployeeRequest request);

  Future<List<Project>> getProject(String baseUrl, CommonGetRequest request);

  Future<Shift?> checkPin(String baseUrl, CheckPinRequest request);
}

class EmployeeRemoteDataSourceImpl implements IEmployeeRemoteDataSource {
  final http.Client httpClient;

  EmployeeRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<Employee>> getEmployee(
      String baseUrl, GetEmployeeRequest request) async {
    List<Employee> employees = [];
    final Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${request.authToken}",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try {
      Uri uri = Uri(
        scheme: urlScheme,
        host: baseUrl,
        port: hostPort,
        path: "$basePath/admin/kiosk/employees",
        queryParameters: {
          'project_id': request.projectId.toString(),
          'employee_filter': request.employeeFilter.toString(),
        },
      );
      cPrint(uri.toString());
      final http.Response result = await http.get(uri, headers: headers);
      cPrint(result.statusCode.toString());

      if (result.statusCode == 200) {
        ResponseModel response =
            ResponseModel.fromJson(jsonDecode(result.body));
        employees = response.data
            .map<Employee>((not) => Employee.fromJson(not))
            .toList();
      } else if (result.statusCode >= 500) {
        logSimpleMessageToCrashlytics(
            "API_Exception", result.statusCode.toString());
        throw ServerException("Something went wrong, please try again!");
      } else if (result.statusCode == 401) {
        throw UnAuthorizedException("Authorization failed, please login back!");
      } else if (result.statusCode >= 400) {
        var response = jsonDecode(result.body);
        if (response != null) throw RequestException(response["message"]);
      } else {
        throw FailureException("Something went wrong, please try again later!");
      }
    } on SocketException catch (e) {
      cPrint(e.message);
      throwWhenSocketException(e);
      return employees;
    } catch (e, t) {
      logInCrashlytics(e.toString(), t);
      cPrint(e.toString());
      throw e;
    }
    return employees;
  }

  @override
  Future<List<Project>> getProject(
      String baseUrl, CommonGetRequest request) async {
    List<Project> projects = [];
    final Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${request.authToken}",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try {
      Uri uri = Uri(
        scheme: urlScheme,
        host: baseUrl,
        port: hostPort,
        path: "$basePath/projects",
      );
      cPrint(uri.toString());
      final http.Response result = await http.get(uri, headers: headers);
      cPrint(result.statusCode.toString());

      if (result.statusCode == 200) {
        ResponseModel response =
            ResponseModel.fromJson(jsonDecode(result.body));
        projects =
            response.data.map<Project>((not) => Project.fromJson(not)).toList();
      } else if (result.statusCode >= 500) {
        logSimpleMessageToCrashlytics(
            "API_Exception", result.statusCode.toString());
        throw ServerException("Something went wrong, please try again!");
      } else if (result.statusCode == 401) {
        throw UnAuthorizedException("Authorization failed, please login back!");
      } else if (result.statusCode >= 400) {
        var response = jsonDecode(result.body);
        if (response != null) throw RequestException(response["message"]);
      } else {
        throw FailureException("Something went wrong, please try again later!");
      }
    } on SocketException catch (e) {
      cPrint(e.message);
      throwWhenSocketException(e);
      return projects;
    } catch (e, t) {
      logInCrashlytics(e.toString(), t);
      cPrint(e.toString());
      throw e;
    }
    return projects;
  }

  @override
  Future<Shift?> checkPin(String baseUrl, CheckPinRequest request) async {
    Shift? shift;

    final Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${request.authToken}",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try {
      Uri uri = Uri(
        scheme: urlScheme,
        host: baseUrl,
        port: hostPort,
        path: "$basePath/admin/kiosk/check/pin",
      );

      cPrint(uri.toString());
      final http.Response result = await http.post(uri,
          headers: headers, body: jsonEncode(request.toMap()));
      if (result.statusCode == 200) {
        ResponseModel response =
            ResponseModel.fromJson(jsonDecode(result.body));
        shift = response.data == null ? null : Shift.fromJson(response.data);
      } else if (result.statusCode >= 500) {
        logSimpleMessageToCrashlytics(
            AppStrings.apiException, result.statusCode.toString());
        // cPrint(result.body.toString());
        throw ServerException(AppStrings.serverExceptionError);
      } else if (result.statusCode == 401) {
        throw UnAuthorizedException(AppStrings.unAuthorizedExceptionError);
      } else if (result.statusCode >= 400) {
        var response = jsonDecode(result.body);
        if (response != null) {
          throw RequestException(response["message"]);
        }
      } else {
        throw FailureException(AppStrings.failureExceptionError);
      }
    } on SocketException catch (e) {
      cPrint(e.message);
      throwWhenSocketException(e);
      return shift;
    } catch (e, t) {
      logInCrashlytics(e.toString(), t);
      cPrint(e.toString());
      throw e;
    }
    return shift;
  }
}
