import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/errors/exceptions.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/features/home/presentation/controllers/home_controller.dart';
import 'package:leyu_mobile/features/withdraw/data/models/bank_model.dart';
import 'package:leyu_mobile/features/withdraw/domain/usecases/withdraw_usecase.dart';

class WithdrawController extends GetxController {
  final WithdrawUsecase _usecase;
  RxDouble walletBalance;

  WithdrawController(this._usecase, {required double initialBalance})
      : walletBalance = initialBalance.obs;

  RxList<BankModel> banks = <BankModel>[].obs;
  RxList<BankModel> filteredBanks = <BankModel>[].obs;
  RxBool isBanksLoading = false.obs;
  RxBool isSubmitting = false.obs;

  Rxn<BankModel> selectedBank = Rxn<BankModel>();

  final searchController = TextEditingController();
  final accountController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBanks();
  }

  @override
  void onClose() {
    searchController.dispose();
    accountController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void fetchBanks() async {
    isBanksLoading.value = true;
    try {
      final result = await _usecase.getBanks();
      banks.value = result;
      filteredBanks.value = result;
    } catch (e) {
      showErrorMessage('withdraw.error_loading_banks'.tr);
    } finally {
      isBanksLoading.value = false;
    }
  }

  void filterBanks(String query) {
    if (query.isEmpty) {
      filteredBanks.value = banks;
    } else {
      filteredBanks.value = banks
          .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectBank(BankModel bank) {
    selectedBank.value = bank;
    accountController.clear();
    amountController.clear();
  }

  String? validateAccount(String value) {
    final bank = selectedBank.value;
    if (bank == null) return null;
    if (value.isEmpty) return 'withdraw.account_required'.tr;
    if (value.length != bank.acctLength) {
      return 'withdraw.account_length_error'
          .trParams({'length': bank.acctLength.toString()});
    }
    return null;
  }

  String? validateAmount(String value) {
    if (value.isEmpty) return 'withdraw.amount_required'.tr;
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) return 'withdraw.amount_invalid'.tr;
    if (amount > walletBalance.value) {
      return 'withdraw.amount_exceeds_balance'
          .trParams({'balance': walletBalance.value.toStringAsFixed(2)});
    }
    return null;
  }

  double get enteredAmount =>
      double.tryParse(amountController.text.trim()) ?? 0.0;

  Future<void> submitWithdrawal() async {
    final bank = selectedBank.value!;
    final account = accountController.text.trim();
    final amount = enteredAmount;

    isSubmitting.value = true;
    try {
      await _usecase.submitWithdrawal(
        bankCode: bank.id.toString(),
        accountNumber: account,
        amount: amount,
      );
      // Refresh balance from API after successful withdrawal
      await _refreshBalance();
      Get.close(2); // close confirmation + account dialogs
      Get.back(); // close bank selection page
      showSuccessMessage('withdraw.success'.tr);
    } catch (e) {
      // Extract the backend message if available, otherwise fall back
      final message = _extractErrorMessage(e);
      showErrorMessage(message);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _refreshBalance() async {
    try {
      final newBalance = await _usecase.getBalance();
      walletBalance.value = newBalance;
      // Sync HomeController so the wallet widget updates immediately
      try {
        Get.find<HomeController>().userBalance.value = newBalance;
      } catch (_) {}
    } catch (_) {
      // Silently fail — balance will refresh on next home visit
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is BadRequestException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is NotFoundException) return e.message;
    if (e is ServerException) return e.message;
    if (e is NetworkException) return e.message;
    if (e is TimeoutException) return e.message;
    return 'withdraw.error_submit'.tr;
  }
}
