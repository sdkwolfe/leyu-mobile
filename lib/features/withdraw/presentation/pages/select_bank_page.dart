import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/widgets/button.dart';
import 'package:leyu_mobile/core/widgets/loading.dart';
import 'package:leyu_mobile/features/withdraw/data/models/bank_model.dart';
import 'package:leyu_mobile/features/withdraw/presentation/controllers/withdraw_controller.dart';

class SelectBankPage extends StatelessWidget {
  const SelectBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WithdrawController>();
    return Scaffold(
      backgroundColor: AppColors.appBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkGray),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'withdraw.select_bank'.tr,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.filterBanks,
              decoration: InputDecoration(
                hintText: 'withdraw.search_bank'.tr,
                hintStyle:
                    const TextStyle(color: AppColors.grayText, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.grayText),
                filled: true,
                fillColor: AppColors.inputBgColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isBanksLoading.value) {
                return const Center(child: LoadingWidget(isTransparent: true));
              }
              if (controller.filteredBanks.isEmpty) {
                return Center(
                    child: Text('withdraw.no_banks'.tr,
                        style: const TextStyle(color: AppColors.grayText)));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredBanks.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.gray),
                itemBuilder: (context, index) {
                  final bank = controller.filteredBanks[index];
                  return _BankTile(
                      bank: bank,
                      onTap: () =>
                          _showAccountDialog(context, controller, bank));
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAccountDialog(
      BuildContext context, WithdrawController controller, BankModel bank) {
    controller.selectBank(bank);
    final formKey = GlobalKey<FormState>();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      bank.isMobileMoney
                          ? Icons.phone_android_rounded
                          : Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(bank.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: AppColors.primary, size: 15),
                          const SizedBox(width: 6),
                          Text('withdraw.available_balance'.tr,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.grayText)),
                          const Spacer(),
                          Text(
                            'ETB ${NumberFormat('#,##0.00').format(controller.walletBalance.value)}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      bank.isMobileMoney
                          ? 'withdraw.enter_phone'.tr
                          : 'withdraw.enter_account'.tr,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.grayText),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.accountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: bank.acctLength,
                      decoration: InputDecoration(
                        hintText: bank.isMobileMoney
                            ? 'withdraw.phone_hint'.trParams(
                                {'length': bank.acctLength.toString()})
                            : 'withdraw.account_hint'.trParams(
                                {'length': bank.acctLength.toString()}),
                        hintStyle: const TextStyle(
                            color: AppColors.grayText, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        counterStyle: const TextStyle(
                            color: AppColors.grayText, fontSize: 10),
                      ),
                      validator: (v) => controller.validateAccount(v ?? ''),
                    ),
                    Text('withdraw.amount_label'.tr,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grayText)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      decoration: InputDecoration(
                        hintText: 'withdraw.amount_hint'.tr,
                        hintStyle: const TextStyle(
                            color: AppColors.grayText, fontSize: 13),
                        prefixText: 'ETB  ',
                        prefixStyle: const TextStyle(
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                        filled: true,
                        fillColor: AppColors.inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                      ),
                      validator: (v) => controller.validateAmount(v ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: ButtonWidget(
                          text: 'common.cancel'.tr,
                          onPressed: () => Get.back(),
                          fill: false,
                          fontSize: 14,
                          height: 42)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ButtonWidget(
                      text: 'common.next'.tr,
                      fontSize: 14,
                      height: 42,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Get.back();
                          _showConfirmationDialog(context, controller, bank);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showConfirmationDialog(
      BuildContext context, WithdrawController controller, BankModel bank) {
    final account = controller.accountController.text.trim();
    final amount = controller.enteredAmount;
    final formattedAmount = 'ETB ${NumberFormat('#,##0.00').format(amount)}';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                    color: AppColors.lightBlue, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                'withdraw.confirm_title'.tr,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.inputBgColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _ConfirmRow(
                      icon: Icons.account_balance_rounded,
                      label: 'withdraw.confirm_bank'.tr,
                      value: bank.name,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _ConfirmRow(
                      icon: bank.isMobileMoney
                          ? Icons.phone_android_rounded
                          : Icons.credit_card_rounded,
                      label: bank.isMobileMoney
                          ? 'withdraw.confirm_phone'.tr
                          : 'withdraw.confirm_account'.tr,
                      value: account,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _ConfirmRow(
                      icon: Icons.payments_rounded,
                      label: 'withdraw.confirm_amount'.tr,
                      value: formattedAmount,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          text: 'common.cancel'.tr,
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () => Get.back(),
                          fill: false,
                          fontSize: 14,
                          height: 42,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ButtonWidget(
                          text: 'withdraw.confirm_button'.tr,
                          fontSize: 14,
                          height: 42,
                          isLoading: controller.isSubmitting.value,
                          loadingText: 'withdraw.submitting'.tr,
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submitWithdrawal,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class _BankTile extends StatelessWidget {
  final BankModel bank;
  final VoidCallback onTap;

  const _BankTile({required this.bank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                bank.isMobileMoney
                    ? Icons.phone_android_rounded
                    : Icons.account_balance_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bank.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray)),
                  const SizedBox(height: 2),
                  Text(
                    bank.isMobileMoney
                        ? 'withdraw.mobile_money'.tr
                        : 'withdraw.bank_account'.tr,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grayText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grayText),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ConfirmRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grayText),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.grayText)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }
}
