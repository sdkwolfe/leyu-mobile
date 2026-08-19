import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/login_response.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  AuthRepository(this._remoteDataSource);

  Future<Either<Failure, LoginResponse>> emailRegister({
    required String email,
    required String password,
    required String firstName,
    String? middleName,
    required String lastName,
    required int age,
    required String gender,
    required String languageId,
    required String dialectId,
  }) async {
    try {
      final response = await _remoteDataSource.emailRegister(
        email: email,
        password: password,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        age: age,
        gender: gender,
        languageId: languageId,
        dialectId: dialectId,
      );
      return Right(response);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, LoginResponse>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      return Right(response);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _remoteDataSource.refreshToken(refreshToken);
      return Right(response);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, void>> requestOtp(String phone) async {
    try {
      final response = await _remoteDataSource.requestOtp(phone);
      return Right(response);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, void>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _remoteDataSource.verifyOtp(phone, otp);
      return Right(response);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, void>> resetPassword(String phone, String otp, String newPassword) async {
    try {
      final response = await _remoteDataSource.resetPassword(phone, otp, newPassword);
      return Right(response);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
