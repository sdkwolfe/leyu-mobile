import 'package:get/get.dart';
import 'package:leyu_mobile/core/services/onboarding_service.dart';
import 'package:leyu_mobile/core/services/onesignal_service.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../../../../core/cache/local_storage.dart';
import '../../../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository _authRepository;
  final LocalStorage _localStorage;

  AuthUseCase(this._authRepository, this._localStorage);

  Future<void> emailRegister({
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
    final result = await _authRepository.emailRegister(
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

    result.fold(
      (failure) {
        showErrorMessage("Registration failed: ${failure.message}");
      },
      (authResponse) async {
        if (checkUserRoleAndRedirect(authResponse.user.role?.name)) {
          showSuccessMessage("Registration successful! Welcome to Leyu.");
          await _localStorage.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          await _localStorage.saveUser(authResponse.user);

          final userId = authResponse.user.id.toString();
          await OneSignalService.loginUser(userId);
          await OneSignalService.setUserTags({
            'role': authResponse.user.role?.name ?? 'unknown',
            'email': authResponse.user.email ?? '',
          });

          Get.offAllNamed(AppRoutes.home);
        } else {
          showErrorMessage("Invalid role. Only Contributors can register via the app.");
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    final result = await _authRepository.login(email, password);
    result.fold(
      (failure) => {showErrorMessage("Login failed: ${failure.message}")},
      (authResponse) async {
        if (checkUserRoleAndRedirect(authResponse.user.role?.name)) {
          showSuccessMessage("Login successful!");
          await _localStorage.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          await _localStorage.saveUser(authResponse.user);

          final userId = authResponse.user.id.toString();
          await OneSignalService.loginUser(userId);

          await OneSignalService.setUserTags({
            'role': authResponse.user.role?.name ?? 'unknown',
            'email': authResponse.user.email ?? '',
          });

          Get.offAllNamed(AppRoutes.home);
        }
      },
    );
  }

  Future<void> checkToken() async {
    String? accessToken = await _localStorage.getAccessToken();
    String? refreshToken = await _localStorage.getRefreshToken();

    if (refreshToken != null &&
        refreshToken.isNotEmpty &&
        accessToken != null &&
        accessToken.isNotEmpty) {
      if (_shouldRefreshToken(accessToken)) {
        final result = await _authRepository.refreshAccessToken(refreshToken);
        result.fold(
          (failure) {
            print("Refreshing Token failed: ${failure.message}");
            Get.offAllNamed(AppRoutes.login);
          },
          (tokens) async {
            await _localStorage.saveTokens(
              accessToken: tokens["accessToken"],
              refreshToken: tokens["refreshToken"],
            );
            Get.offAllNamed(AppRoutes.home);
          },
        );
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      if (OnboardingService.hasSeenIntroduction()) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.introduction);
      }
    }
  }

  Future<void> refreshToken() async {
    String? accessToken = await _localStorage.getAccessToken();
    String? refreshToken = await _localStorage.getRefreshToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final result = await _authRepository.refreshAccessToken(refreshToken);
        result.fold(
          (failure) {
            print("Refreshing Token failed: ${failure.message}");
            Get.offAllNamed(AppRoutes.login);
          },
          (tokens) async {
            await _localStorage.saveTokens(
              accessToken: tokens["accessToken"],
              refreshToken: tokens["refreshToken"],
            );

            final user = await _localStorage.getUserDetail();
            if (user != null && user.id != null) {
              await OneSignalService.loginUser(user.id!);
            }
          },
        );
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  bool _shouldRefreshToken(String token) {
    try {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      if (decodedToken.containsKey("exp")) {
        int expiryTimestamp = decodedToken["exp"] * 1000;
        int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        int remainingTimeMs = expiryTimestamp - currentTimestamp;
        int remainingTimeMinutes = (remainingTimeMs / (60 * 1000)).floor();
        return remainingTimeMinutes <= 3;
      }
    } catch (e) {
      print("Error decoding access token: $e");
    }
    return true;
  }

  bool checkUserRoleAndRedirect(String? role) {
    return role == "Contributor";
  }
}
