//
// import 'package:dartz/dartz.dart';
// import 'package:excalibur_employee/src/core/domain/usecases/usecase.dart';
// import 'package:excalibur_employee/src/core/error/failures.dart';
// import 'package:excalibur_employee/src/feature/authentication/domain/repositories/authentication.repository.dart';
//
// class PostFcmTokenUsecase implements UseCase<bool, Params> {
//   final AuthenticationRepository repository;
//
//   PostFcmTokenUsecase(this.repository);
//
//   @override
//   Future<Either<Failure, bool>> call(Params params) async {
//     return repository.submitFcmToken(params.baseUrl, params.token, params.authToken);
//   }
//
//   void saveFcmToken(String? token) {
//     repository.saveFcmToken(token);
//   }
//
// }
//
// class Params {
//   final String baseUrl;
//   final String? token;
//   final String? authToken;
//
//   Params(this.baseUrl, this.token, this.authToken);
// }