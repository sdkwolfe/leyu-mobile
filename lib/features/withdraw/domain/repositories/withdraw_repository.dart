import 'package:leyu_mobile/features/withdraw/data/datasources/withdraw_remote_data_source.dart';
import 'package:leyu_mobile/features/withdraw/data/models/bank_model.dart';

class WithdrawRepository {
  final WithdrawRemoteDataSource _dataSource;

  WithdrawRepository(this._dataSource);

  Future<List<BankModel>> getBanks() => _dataSource.getBanks();

  Future<double> getBalance() => _dataSource.getBalance();

  Future<void> submitWithdrawal({
    required String bankCode,
    required String accountNumber,
    required double amount,
  }) =>
      _dataSource.submitWithdrawal(
        bankCode: bankCode,
        accountNumber: accountNumber,
        amount: amount,
      );
}
