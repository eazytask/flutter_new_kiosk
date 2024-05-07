import 'dart:convert';
import 'dart:io';

import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/data/models/response.model.dart';
import 'package:kiosk/src/core/error/exception.dart';
import 'package:kiosk/src/core/error/socket_exception_handle.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/domain/entities/authentication.entity.dart';
import 'package:http/http.dart' as http;
import 'package:kiosk/src/core/error/logger.dart' show cPrint, logInCrashlytics, logSimpleMessageToCrashlytics;

abstract class AuthenticationRemoteDataSource {

  Future<Authentication> login(String baseUrl, AuthRequest authRequest);
  Future<bool> logout(String baseUrl, String? authToken);
  // Future<bool> removeFcmTokenApi(String baseUrl, String? fcmToken, String? authToken);
  // Future<bool> submitFcmToken(String baseUrl, String? token, String? authToken);
  // Future<User> postVerifyCode(VerifyActivationRequest request);
}

class AuthenticationRemoteDataSourceImpl implements AuthenticationRemoteDataSource {
  final http.Client httpClient;

  AuthenticationRemoteDataSourceImpl(this.httpClient);

  @override
  Future<Authentication> login(String baseUrl, AuthRequest authRequest) async {

    Uri uri = Uri(
      scheme: urlScheme,
      host: baseUrl,
      port: hostPort,
      path: "$basePath/admin/login",
    );
    cPrint(uri.toString());

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
    };

    try {
      final http.Response result = await httpClient.post(uri,
          body: jsonEncode(authRequest.toMap()), headers: headers);

      cPrint(result.statusCode.toString());

      if (result.statusCode == 200) {
        var responseBody = json.decode(result.body);
        var responseModel = ResponseModel.fromJson(responseBody);
        if (responseModel.success) {
          return Authentication.fromJson(responseModel.data);
        }
        throw RequestException(responseModel.message.toString());
      } else if (result.statusCode >= 500) {
        logSimpleMessageToCrashlytics("API_Exception", result.body.toString());
        // cPrint(result.body.toString());
        throw ServerException("Something went wrong, please try again!");
      } else if (result.statusCode == 401) {
        throw UnAuthorizedException("Authentication failed");
      } else if (result.statusCode == 403) {
        var response = jsonDecode(result.body);
        throw AccountDeactivatedException(response["message"]);
      } else if (result.statusCode >= 400) {
        var response = jsonDecode(result.body);
        if (response != null) {
          throw RequestException(response["message"]);
        }
      }

      throw UserNotFoundException();
    } on SocketException catch (e) {
      cPrint(e.message);
      throwWhenSocketException(e);
      return Authentication.fromJson({});
    } catch (e, t) {
      if (e is RequestException) {
        logInCrashlytics(e.message, t);
      } else {
        logInCrashlytics(e.toString(), t);
      }
      cPrint(e.toString());
      throw e;
    }
  }

  @override
  Future<bool> logout(String baseUrl, String? authToken) async {

    Uri uri = Uri(
      scheme: urlScheme,
      host: baseUrl,
      port: hostPort,
      path: "$basePath/logout",
    );
    cPrint(uri.toString());

    var headers = {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
    };
    try {
      ;
      final http.Response result = await httpClient.post(uri, headers: headers);

      cPrint(result.statusCode.toString());

      if (result.statusCode == 200) {
        var responseBody = json.decode(result.body);
        if (responseBody != null) {
          var responseModel = ResponseModel.fromJson(responseBody);
          if (responseModel.success) {
            return responseModel.success;
          }else {
            throw RequestException(responseModel.message.toString());
          }
        }
        throw RequestException(responseBody["message"]);
      } else if (result.statusCode >= 500) {
        logSimpleMessageToCrashlytics("API_Exception_${result.statusCode}", result.body);
        throw ServerException("Something went wrong, please try again!");
      } else if (result.statusCode == 401) {
        throw UnAuthorizedException("Authentication failed");
      } else if (result.statusCode >= 400) {
        logSimpleMessageToCrashlytics("API_Exception_${result.statusCode}", result.body);
        var response = jsonDecode(result.body);
        if (response != null) {
          throw RequestException(response["message"]?.toString() ?? "");
        }
      }

      throw UserNotFoundException();
    } on SocketException catch (e) {
      cPrint(e.message);
      throwWhenSocketException(e);
      return false;
    } catch (e, t) {
      logInCrashlytics(e.toString(), t);
      cPrint(e.toString());
      rethrow;
    }
  }
  //
  // @override
  // Future<bool> removeFcmTokenApi(String baseUrl, String? fcmToken, String? authToken) async {
  //
  //   Uri uri = Uri(
  //     scheme: urlScheme,
  //     host: baseUrl,
  //     port: hostPort,
  //     path: "$basePath/fcm-token",
  //   );
  //   cPrint(uri.toString());
  //
  //   var headers = {
  //     HttpHeaders.authorizationHeader: "Bearer $authToken",
  //     HttpHeaders.contentTypeHeader: "application/json",
  //     HttpHeaders.acceptHeader: "application/json",
  //   };
  //   try {
  //     final String userAgent = await deviceInfo.getUserAgent();
  //     final http.Response result = await httpClient.put(uri,
  //         body: jsonEncode({
  //           "token": fcmToken,
  //           "deviceDetails": userAgent,
  //         }), headers: headers);
  //
  //     cPrint(result.statusCode.toString());
  //
  //     if (result.statusCode == 200) {
  //       var responseBody = json.decode(result.body);
  //       var responseModel = ResponseModel.fromJson(responseBody);
  //       if (responseModel.success)
  //         return responseModel.data['logged'] ?? true;
  //       throw RequestException(responseModel.message.toString());
  //     } else if (result.statusCode >= 500) {
  //       logSimpleMessageToCrashlytics("API_Exception_${result.statusCode}", result.body);
  //       throw ServerException("Something went wrong, please try again!");
  //     } else if (result.statusCode == 401) {
  //       throw UnAuthorizedException("Authentication failed");
  //     } else if (result.statusCode >= 400) {
  //       logSimpleMessageToCrashlytics("API_Exception_${result.statusCode}", result.body);
  //       var response = jsonDecode(result.body);
  //       if (response != null) {
  //         throw RequestException(response["message"]?.toString() ?? "");
  //       }
  //     }
  //
  //     throw UserNotFoundException();
  //   } on SocketException catch (e) {
  //     cPrint(e.message);
  //     throwWhenSocketException(e);
  //     return false;
  //   } catch (e, t) {
  //     logInCrashlytics(e.toString(), t);
  //     cPrint(e.toString());
  //     rethrow;
  //   }
  // }
  //
  // @override
  // Future<bool> submitFcmToken(String baseUrl, String? token, String? authToken) async {
  //
  //   Uri uri = Uri(
  //     scheme: urlScheme,
  //     host: baseUrl,
  //     port: hostPort,
  //     path: "$basePath/push-token",
  //   );
  //   cPrint(uri.toString());
  //
  //   var headers = {
  //     HttpHeaders.authorizationHeader: "Bearer $authToken",
  //     HttpHeaders.contentTypeHeader: "application/json",
  //     HttpHeaders.acceptHeader: "application/json",
  //   };
  //   try {
  //     final String userAgent = await deviceInfo.getUserAgent();
  //     var deviceType = deviceInfo.type.toLowerCase();
  //
  //     final http.Response result = await httpClient.post(uri,
  //         body: jsonEncode({
  //           "token": token,
  //           "deviceType": deviceType,
  //           "deviceDetails": userAgent,
  //         }), headers: headers);
  //
  //     cPrint(result.statusCode.toString());
  //
  //     if (result.statusCode == 200) {
  //       var responseBody = json.decode(result.body);
  //       var responseModel = ResponseModel.fromJson(responseBody);
  //       if (responseModel.success) {
  //         return responseModel.data != null && responseModel.data == 1;
  //       }
  //       throw RequestException(responseModel.message.toString());
  //     } else if (result.statusCode >= 500) {
  //       logSimpleMessageToCrashlytics("API_Exception", result.statusCode.toString());
  //       throw ServerException("Something went wrong, please try again!");
  //     } else if (result.statusCode == 401) {
  //       throw UnAuthorizedException("Authentication failed");
  //     } else if (result.statusCode >= 400) {
  //       var response = jsonDecode(result.body);
  //       if (response != null) {
  //         throw RequestException(response["message"]?.toString() ?? "Something went wrong");
  //       }
  //     }
  //
  //     throw UserNotFoundException();
  //   } on SocketException catch (e) {
  //     cPrint(e.message);
  //     throwWhenSocketException(e);
  //     return false;
  //   } catch (e, t) {
  //     logInCrashlytics(e.toString(), t);
  //     cPrint(e.toString());
  //     rethrow;
  //   }
  // }
  //
  // @override
  // Future<User> postVerifyCode(VerifyActivationRequest request) async {
  //   final Map<String, String> headers = {
  //     HttpHeaders.contentTypeHeader: "application/json",
  //     HttpHeaders.acceptHeader: "application/json"
  //   };
  //
  //   try {
  //     Uri uri = Uri(
  //       scheme: urlScheme,
  //       host: request.baseUrl,
  //       port: hostPort,
  //       path: "$basePath/verify-activation",
  //     );
  //     cPrint(uri.toString());
  //
  //     final http.Response result = await http.post(uri,
  //         headers: headers,
  //         body: jsonEncode(request.toMap())
  //     );
  //
  //     cPrint(result.statusCode.toString());
  //
  //     if (result.statusCode == 200) {
  //       ResponseModel response = ResponseModel.fromJson(jsonDecode(result.body));
  //       if (response.success) {
  //         return UserModel.fromJson(response.data);
  //       }
  //     } else if (result.statusCode >= 500) {
  //       // cPrint(result.body.toString());
  //       throw ServerException("Something went wrong, please try again!");
  //     } else if (result.statusCode >= 400) {
  //       String message = generateErrorMessage(result);
  //       throw RequestException(message);
  //     }
  //     return UserModel.fromJson({});
  //   } on SocketException catch (e) {
  //     cPrint(e.message);
  //     throwWhenSocketException(e);
  //     return UserModel.fromJson({});
  //   } catch (e, _) {
  //     cPrint(e.toString());
  //     rethrow;
  //   }
  // }
  //
  // String generateErrorMessage(http.Response result) {
  //   // cPrint(result.body.toString());
  //   var response = jsonDecode(result.body);
  //   var message = "Something went wrong";
  //   if (response["errors"] != null) {
  //     message = response["errors"]["message"].toString();
  //   } else {
  //     message = response["message"].toString();
  //   }
  //   return message;
  // }

}
