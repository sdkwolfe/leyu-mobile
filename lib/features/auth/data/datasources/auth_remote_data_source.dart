import 'package:dio/dio.dart';
import '../../../../../core/api/api_client.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSource(this._apiClient);

  // NEW: Single-step Email Registration (Bypasses SMS/OTP)
  Future<LoginResponse> emailRegister({
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
      // 1. Register the user
      await _apiClient.post('/iam/users/email-register', data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'middle_name': middleName ?? '',
        'last_name': lastName,
        'age': age,
        'gender': gender,
        'language_id': languageId,
        'dialect_id': dialectId,
      });

      // 2. Auto-login immediately to get the JWT tokens
      return await login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/iam/auth/mobile_login', data: {
        'username': email,
        'password': password,
        "device_token": "string",
        "device_type": "android",
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post('/iam/auth/refresh-token',
          data: {'refresh_token': refreshToken});
      return {
        "accessToken": response.data["data"]["access_token"],
        "refreshToken": response.data["data"]["new_refresh_token"]
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    try {
      await _apiClient.post('/iam/auth/forgot-password', data: {
        'username': phoneNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    try {
      await _apiClient.post('/iam/auth/verify-otp', data: {
        'username': phoneNumber,
        'code': otp,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String phone, String otp, String newPassword) async {
    try {
      await _apiClient.post('/iam/auth/reset-password', data: {
        'username': phone,
        'code': otp,
        'password': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
}
