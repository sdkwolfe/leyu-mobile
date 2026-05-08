import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/features/auth/data/models/dialect.dart';
import 'package:leyu_mobile/features/auth/data/models/dialect.dart';
import 'package:leyu_mobile/features/auth/data/models/dialect.dart';
import 'package:leyu_mobile/features/auth/data/models/language.dart';

import '../../../../../core/api/api_client.dart';
import '../models/login_response.dart';
import '../models/verification_response.dart';
class BaseDataRemoteDataSource {
  final ApiClient _apiClient;

  BaseDataRemoteDataSource(this._apiClient);

  Future<List<Language>> getLanguages() async {
    final response = await _apiClient.get('/setting/language/all');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data["data"];
      return data.map((lang) => Language.fromJson(lang)).toList();
    } else {
      throw Exception('Failed to load languages');
    }
  }

  Future<List<Dialect>> getDialects(String languageId) async {
    final response = await _apiClient.get('/setting/dialect/language/$languageId');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data["data"];
      return data.map((lang) => Dialect.fromJson(lang)).toList();
    } else {
      throw Exception('Failed to load dialects');
    }
  }
}
