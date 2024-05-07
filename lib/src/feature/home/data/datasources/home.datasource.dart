import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/data/models/response.model.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/error/exception.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/core/error/socket_exception_handle.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/feature/home/data/models/sign_in_out_request.model.dart';
import 'package:kiosk/src/feature/home/data/models/start_unscheduled_shift_request.model.dart';
import 'package:http/http.dart' as http;

abstract class IHomeRemoteDataSource {
  Future<List<JobType>> getJobTypes(String baseUrl, CommonGetRequest request);

  Future<Shift?> startUnscheduledShift(
      String baseUrl, StartUnscheduledShiftRequest request);

  Future<bool> signInAndOut(
      String baseUrl, String path, SignInAndOutRequest request);
}

class HomeRemoteDataSourceImpl implements IHomeRemoteDataSource {
  final http.Client httpClient;

  HomeRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<JobType>> getJobTypes(
      String baseUrl, CommonGetRequest request) async {
    List<JobType> jobTypes = [];
    final Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${request.authToken}",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try {
      Uri uri = Uri(
        scheme: urlScheme,
        host: baseUrl,
        port: hostPort,
        path: "$basePath/job/type",
      );
      cPrint(uri.toString());
      final http.Response result = await http.get(uri, headers: headers);
      cPrint(result.statusCode.toString());

      if (result.statusCode == 200) {
        ResponseModel response =
            ResponseModel.fromJson(jsonDecode(result.body));
        jobTypes =
            response.data.map<JobType>((not) => JobType.fromJson(not)).toList();
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
      return jobTypes;
    } catch (e, t) {
      logInCrashlytics(e.toString(), t);
      cPrint(e.toString());
      throw e;
    }
    return jobTypes;
  }

  @override
  Future<Shift?> startUnscheduledShift(
      String baseUrl, StartUnscheduledShiftRequest request) async {
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
        path: "$basePath/admin/kiosk/start/unschedule",
      );

      cPrint(uri.toString());
      final http.Response result = await http.post(uri,
          headers: headers, body: jsonEncode(request.toMap()));

      if (result.statusCode == 200) {
        ResponseModel response =
            ResponseModel.fromJson(jsonDecode(result.body));

        return shift = Shift.fromJson(response.data);
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

  @override
  Future<bool> signInAndOut(
      String baseUrl, String path, SignInAndOutRequest request) async {
    final Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${request.authToken}",
      HttpHeaders.contentTypeHeader: "application/json",
    };

    try {
      Uri uri = Uri(
        scheme: urlScheme,
        host: baseUrl,
        port: hostPort,
        path: "$basePath/$path",
      );

      cPrint(uri.toString());

      final http.Response result = await http.post(uri,
          headers: headers, body: jsonEncode(request.toMap()));

      if (result.statusCode == 200) {
        ResponseModel response =
            ResponseModel.fromJson(jsonDecode(result.body));
        return response.success;
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
      return false;
    } catch (e, t) {
      logInCrashlytics(e.toString(), t);
      cPrint(e.toString());
      throw e;
    }
    return false;
  }
}
