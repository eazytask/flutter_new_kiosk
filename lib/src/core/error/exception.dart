class FailureException implements Exception {
  final String message;

  FailureException(this.message);
}

class ServerException implements FailureException {
  final String message;

  ServerException(this.message);
}

class NetworkException implements FailureException {
  final String message;

  NetworkException(this.message);
}

class UserNotFoundException implements FailureException {
  final String message = "User not found!";
}

class RequestException implements FailureException {
  final String message;

  RequestException(this.message);
}
class ProcessingFailedException extends FailureException {
  ProcessingFailedException(String message) : super(message);
}

class TokenExpiredException extends FailureException {
  TokenExpiredException(String message) : super(message);
}

class InternetConnectionException extends FailureException {
  InternetConnectionException(String message) : super(message);
}

class TimeoutConnectionException extends FailureException {
  TimeoutConnectionException(String message) : super(message);
}
class NotFoundException extends FailureException {
  NotFoundException(String message) : super(message);
}

class UnAuthorizedException extends FailureException {
  UnAuthorizedException(String message) : super(message);
}

class AccountDeactivatedException extends FailureException {
  AccountDeactivatedException(String message) : super(message);
}