import 'package:dio/dio.dart';
import 'package:leyu_mobile/core/api/api_client.dart';
import 'package:leyu_mobile/features/auth/data/models/user.dart';

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource(this._apiClient);

  Future<User> getUserProfile() async {
    final response = await _apiClient.get('/iam/users/me');
    print(response.data);
    if (response.statusCode == 200) {
      return User.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch user profile');
  }

  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    final response = await _apiClient.put('/iam/users/me', data: profileData);
    return response.statusCode == 200;
  }

  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      print('Uploading profile picture with data: $formData');
      final response =
          await _apiClient.put('/iam/users/profile', data: formData);
      if (response.statusCode == 200) {
        return response.data['data']['profile_picture'];
      }
      print(response.data);
      return null;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final response = await _apiClient.put('/iam/users/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    return response.statusCode == 200;
  }

  Future<bool> uploadNationalId(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      print('Uploading national ID with data: $formData');
      final response =
          await _apiClient.patch('/iam/users/national_id', data: formData);
      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading national ID: $e');
      return false;
    }
  }

  Future<bool> applyReferralCode(String referralCode) async {
    final response = await _apiClient.patch('/iam/users/referral_code', data: {
      'referral_code': referralCode,
    });
    return response.statusCode == 200;
  }

  Future<bool> updatePreferredLanguage(String languageCode) async {
    print('Updating preferred language to: $languageCode');
    final response = await _apiClient.patch('/iam/users/preferred-language', data: {
      'language_key': languageCode,
    });
    return response.statusCode == 200;
  }
}
