import 'package:leyu_mobile/features/withdraw/data/models/bank_model.dart';
import 'package:leyu_mobile/features/withdraw/domain/repositories/withdraw_repository.dart';

class WithdrawUsecase {
  final WithdrawRepository _repository;

  WithdrawUsecase(this._repository);

  Future<List<BankModel>> getBanks() => _repository.getBanks();

  Future<double> getBalance() => _repository.getBalance();

  Future<void> submitWithdrawal({
    required String bankCode,
    required String accountNumber,
    required double amount,
  }) =>
      _repository.submitWithdrawal(
        bankCode: bankCode,
        accountNumber: accountNumber,
        amount: amount,
      );
}
