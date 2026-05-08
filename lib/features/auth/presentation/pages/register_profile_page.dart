import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/widgets/loading.dart';
import 'package:leyu_mobile/features/auth/presentation/widgets/register_terms_conditions_widget.dart';
import 'package:leyu_mobile/features/auth/presentation/widgets/register_user_info_widget.dart';
import '../controllers/auth_controller.dart';
import '../widgets/register_additional_info.dart';
import '../widgets/register_password_widget.dart';

class RegisterProfilePage extends StatelessWidget {
  final AuthController _authController = Get.find();

  RegisterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: !_authController.isRegisteringProfile.value,
          child: Scaffold(
            backgroundColor: AppColors.appBgColor,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: LoadingOverlayWidget(
              isLoading: [_authController.isRegisteringProfile],
              reason: _authController.registerProfileLoadingReason,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Obx(() {
                    int currentPage = _authController.currentPage.value;
                    return currentPage == 0
                        ? RegisterUserInfoWidget()
                        : currentPage == 1
                            ? RegisterTermsConditionsWidget()
                            : currentPage == 2
                                ? const RegisterAdditionalInfoWidget()
                                : currentPage == 3
                                    ? RegisterPasswordWidget()
                                    : Container();
                  })),
            )),
          ),
        ));
  }
}
