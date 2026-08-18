import 'package:dartz/dartz.dart';
import 'package:leyu_mobile/features/auth/data/models/new_user.dart';
import 'package:leyu_mobile/features/auth/data/models/verification_response.dart';
import '../../../../../core/errors/failure.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/login_response.dart';
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  AuthRepository(this._remoteDataSource);
  Future<Either<Failure, String>> register(String phone) async {
    try {
      final response = await _remoteDataSource.register(phone);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure, VerificationResponse>> activateAccount(String verificationId , String phone, String otp) async {
    try {
      final response = await _remoteDataSource.activateAccount(verificationId , phone , otp);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure, void>> registerProfile(NewUser newUser) async {
    try {
      final response = await _remoteDataSource.registerProfile(newUser);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure, LoginResponse>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure,Map<String , dynamic>>> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _remoteDataSource.refreshToken(refreshToken);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure, void>> requestOtp(String phone) async {
    try {
      final response = await _remoteDataSource.requestOtp(phone);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure, void>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _remoteDataSource.verifyOtp(phone , otp);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
  Future<Either<Failure, void>> resetPassword(String phone, String otp , String newPassword) async {
    try {
      final response = await _remoteDataSource.resetPassword(phone , otp , newPassword);
      return Right(response);
    }
    on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
