import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);
}

//General Failures
class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}

class ConnectionFailure extends Failure {
  final String message;

  const ConnectionFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}

class TimeoutFailure extends Failure {
  final String message;

  const TimeoutFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}

class AccountDeactivatedFailure extends Failure {
  final String message;

  const AccountDeactivatedFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}


class UnAuthorizedFailure extends Failure {
  final String message;

  const UnAuthorizedFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}

class AppFailure extends Failure {
  final String message;

  const AppFailure(this.message) : super(message);

  @override
  List<Object> get props => [];
}