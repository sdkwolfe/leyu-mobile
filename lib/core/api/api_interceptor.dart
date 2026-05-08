import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:async';

import 'package:leyu_mobile/routes/app_routes.dart';

import '../cache/local_storage.dart';
import 'api_constants.dart';

class ApiInterceptor extends Interceptor {
  final LocalStorage _localStorage = LocalStorage();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print("🔹 Request Method: ${options.method}");
    print("🔹 Request URL: ${options.uri}");
    if (options.uri.toString().contains("iam/auth") ||
        options.uri.toString().contains("iam/users/sign-up") ||
        options.uri.toString().contains("iam/users/verify") ||
        options.uri.toString().contains("setting")) {
      return handler.next(options);
    }
    String? accessToken = await _localStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      if (_shouldRefreshToken(accessToken)) {
        try {
          print("Refreshing token...");
          accessToken = await _getNewTokens();
          print("token refreshed successfully!");
        } catch (e) {
          print("Error refreshing token: $e");
          Get.offAllNamed(AppRoutes.login);
          return handler
              .reject(DioException(requestOptions: options, error: e));
        }
      }
      options.headers["Authorization"] = "Bearer $accessToken";
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Checks if the token should be refreshed (expires in <= 0 minutes)
  bool _shouldRefreshToken(String token) {
    try {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      if (decodedToken.containsKey("exp")) {
        int expiryTimestamp = decodedToken["exp"] * 1000;
        int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        int remainingTimeMs = expiryTimestamp - currentTimestamp;
        int remainingTimeMinutes = (remainingTimeMs / (60 * 1000)).floor();
        print("Access token expires in: $remainingTimeMinutes minutes");
        return remainingTimeMinutes <= 0.5;
      }
    } catch (e) {
      print("Error decoding access token: $e");
    }
    return true;
  }

  /// Refreshes the access token using the refresh token
  Future<String> _getNewTokens() async {
    final refreshToken = await _localStorage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final response = await Dio().post(
            "${ApiConstants.baseUrl}/auth/refresh-access-token",
            data: {"refreshToken": refreshToken});
        if (response.statusCode == 200) {
          final newAccessToken = response.data["accessToken"];
          final newRefreshToken = response.data["refreshToken"];
          await _localStorage.saveTokens(
              accessToken: newAccessToken, refreshToken: newRefreshToken);
          return newAccessToken;
        } else {
          throw Exception("Failed to refresh token");
        }
      } catch (e) {
        throw Exception("Error refreshing token");
      }
    } else {
      throw Exception("No refresh token found");
    }
  }
}
