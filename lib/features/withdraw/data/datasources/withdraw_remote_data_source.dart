import 'dart:math';
import 'package:dio/dio.dart';
import 'package:leyu_mobile/core/api/api_client.dart';
import 'package:leyu_mobile/core/api/api_constants.dart';
import 'package:leyu_mobile/features/withdraw/data/models/bank_model.dart';

class WithdrawRemoteDataSource {
  final ApiClient _apiClient;

  WithdrawRemoteDataSource(this._apiClient);

  /// Fetches available banks from GET /wallet/get-withdraw-options
  Future<List<BankModel>> getBanks() async {
    final response = await _apiClient.get(ApiConstants.withdrawOptions);
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => BankModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches current wallet balance from GET /wallet/balance
  Future<double> getBalance() async {
    final response = await _apiClient.get('/wallet/balance');
    return double.parse(response.data['data'].toString());
  }

  /// Submits a withdrawal request via POST /wallet/withdraw-money
  Future<void> submitWithdrawal({
    required String bankCode,
    required String accountNumber,
    required double amount,
  }) async {
    final idempotencyKey =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
    print(idempotencyKey);
    await _apiClient.post(
      ApiConstants.withdrawMoney,
      data: {
        'account_number': accountNumber,
        'amount': amount,
        'bank_code': bankCode,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {'x-idempotency-key': idempotencyKey},
      ),
    );
  }
}
