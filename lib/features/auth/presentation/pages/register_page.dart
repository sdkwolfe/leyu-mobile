import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/widgets/button.dart';
import 'package:leyu_mobile/core/widgets/language_changer.dart';
import 'package:leyu_mobile/core/widgets/loading.dart';
import 'package:leyu_mobile/routes/app_routes.dart';
import 'package:leyu_mobile/features/auth/domain/entities/dialect_entity.dart';
import 'package:leyu_mobile/features/auth/domain/entities/language_entity.dart';
import '../../../../../core/utils/screen_size.dart';
import '../../../../../core/widgets/input_box.dart';
import '../../../../../core/widgets/dropdown.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController _authController = Get.find();

  // Controllers for Step 0 (Credentials)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controllers for Step 1 (Profile)
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  RxnString selectedGender = RxnString(null);
  final List<String> genderOptions = ['Male', 'Female'];

  // Controllers for Step 2 (Language)
  RxnString selectedLanguageId = RxnString(null);
  RxnString selectedDialectId = RxnString(null);

  final formKey0 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  RegisterPage({super.key}) {
    // Reset state when page opens
    _authController.currentPage.value = 0;
    _authController.languages.clear();
    _authController.dialects.clear();
    _authController.getLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: !_authController.isEmailRegistering.value,
      child: Scaffold(
        backgroundColor: AppColors.appBgColor,
        body: SafeArea(
          child: LoadingOverlayWidget(
            isLoading: [_authController.isEmailRegistering],
            reason: _authController.emailRegisterLoadingReason,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: getScreenHeight(context)*0.025),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_authController.currentPage.value > 0) {
                                    _authController.currentPage.value--;
                                  } else {
                                    Get.back();
                                  }
                                },
                                child: const Icon(Icons.arrow_back, size: 26),
                              ),
                              const Spacer(),
                              LanguageChanger()
                            ],
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.025),
                          Text(
                            _authController.currentPage.value == 0 ? "Create Account".tr : 
                            _authController.currentPage.value == 1 ? "Profile Info".tr : "Language & Dialect".tr,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.01),
                          Text(
                            "Step ${_authController.currentPage.value + 1} of 3",
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          SizedBox(height: getScreenHeight(context) * 0.02),
                          
                          // STEP 0: Credentials
                          if (_authController.currentPage.value == 0) _buildStep0(context),
                          
                          // STEP 1: Profile Info
                          if (_authController.currentPage.value == 1) _buildStep1(context),
                          
                          // STEP 2: Language & Dialect
                          if (_authController.currentPage.value == 2) _buildStep2(context),
                        ],
                      ),
                    ),
                  ),
                  
                  // Navigation Buttons
                  _buildBottomButton(context),
                  
                  SizedBox(height: getScreenHeight(context)*0.025),
                ],
              ),
            ),
          )
        ),
      ),
    ));
  }

  Widget _buildStep0(BuildContext context) {
    return Form(
      key: formKey0,
      child: Column(
        children: [
          InputBoxWidget(
            inputType: InputType.text, 
            label: "Email".tr,
            placeHolder: "Enter your email".tr,
            controller: _emailController,
            showLabel: true,
          ),
          SizedBox(height: getScreenHeight(context)*0.015),
          InputBoxWidget(
            inputType: InputType.password,
            label: "Password".tr,
            placeHolder: "Create a password (min 6 chars)".tr,
            controller: _passwordController,
            showLabel: true,
          ),
          SizedBox(height: getScreenHeight(context)*0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("auth.register.have_account".tr),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.login),
                child: Text(
                  "auth.register.login".tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: AppColors.primary),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Form(
      key: formKey1,
      child: Column(
        children: [
          InputBoxWidget(
            inputType: InputType.text,
            label: "First Name".tr,
            placeHolder: "First Name".tr,
            controller: _firstNameController,
            showLabel: true,
          ),
          SizedBox(height: getScreenHeight(context)*0.01),
          InputBoxWidget(
            inputType: InputType.text,
            label: "Middle Name (Optional)".tr,
            placeHolder: "Middle Name".tr,
            controller: _middleNameController,
            showLabel: true,
            isOptional: true,
          ),
          SizedBox(height: getScreenHeight(context)*0.01),
          InputBoxWidget(
            inputType: InputType.text,
            label: "Last Name".tr,
            placeHolder: "Last Name".tr,
            controller: _lastNameController,
            showLabel: true,
          ),
          SizedBox(height: getScreenHeight(context)*0.01),
          InputBoxWidget(
            inputType: InputType.number,
            label: "Age".tr,
            placeHolder: "12 - 120",
            controller: _ageController,
            showLabel: true,
          ),
          SizedBox(height: getScreenHeight(context)*0.01),
          Obx(() => DropdownBoxWidget<String>(
            label: "Gender".tr,
            items: genderOptions,
            selectedItem: selectedGender.value,
            showLabel: true,
            isOptional: false,
            placeHolder: "Select Gender".tr,
            onChanged: (value) => selectedGender.value = value,
          )),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Form(
      key: formKey2,
      child: Column(
        children: [
          Obx(() {
            if (_authController.isLoadingLanguages.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return DropdownBoxWidget<LanguageEntity>(
              label: "Language".tr,
              items: _authController.languages.toList(),
              selectedItem: _authController.languages.firstWhereOrNull((l) => l.id == selectedLanguageId.value),
              showLabel: true,
              isOptional: false,
              placeHolder: "Select Language".tr,
              displayText: (lang) => lang.name,
              onChanged: (value) {
                if (value != null) {
                  selectedLanguageId.value = value.id;
                  selectedDialectId.value = null;
                  _authController.getDialects(value.id);
                }
              },
            );
          }),
          SizedBox(height: getScreenHeight(context)*0.015),
          Obx(() {
            if (selectedLanguageId.value == null) {
              return const SizedBox.shrink();
            }
            if (_authController.isLoadingDialects.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return DropdownBoxWidget<DialectEntity>(
              label: "Dialect".tr,
              items: _authController.dialects.toList(),
              selectedItem: _authController.dialects.firstWhereOrNull((d) => d.id == selectedDialectId.value),
              showLabel: true,
              isOptional: false,
              placeHolder: "Select Dialect".tr,
              displayText: (dialect) => dialect.name,
              onChanged: (value) {
                if (value != null) {
                  selectedDialectId.value = value.id;
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Obx(() {
      if (_authController.currentPage.value == 0) {
        return ButtonWidget(
          text: "Next".tr,
          fontSize: 16,
          onPressed: () {
            if (formKey0.currentState!.validate()) {
              if (_emailController.text.trim().isEmpty || _passwordController.text.trim().length < 6) {
                Get.snackbar("Error", "Please enter a valid email and password (min 6 chars)");
                return;
              }
              _authController.saveCredentialsAndNext(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
            }
          },
        );
      } else if (_authController.currentPage.value == 1) {
        return ButtonWidget(
          text: "Next".tr,
          fontSize: 16,
          onPressed: () {
            if (formKey1.currentState!.validate()) {
              final age = int.tryParse(_ageController.text.trim());
              if (age == null || age < 12 || age > 120) {
                Get.snackbar("Error", "Age must be between 12 and 120");
                return;
              }
              if (selectedGender.value == null) {
                Get.snackbar("Error", "Please select a gender");
                return;
              }
              _authController.saveProfileAndNext(
                _firstNameController.text.trim(),
                _middleNameController.text.trim(),
                _lastNameController.text.trim(),
                _ageController.text.trim(),
                selectedGender.value!,
                null, // nationalId
              );
            }
          },
        );
      } else {
        return ButtonWidget(
          text: "Create Account".tr,
          loadingText: "Creating...".tr,
          fontSize: 16,
          isLoading: _authController.isEmailRegistering.value,
          onPressed: () {
            if (formKey2.currentState!.validate()) {
              if (selectedLanguageId.value == null || selectedDialectId.value == null) {
                Get.snackbar("Error", "Please select both language and dialect");
                return;
              }
              _authController.saveLanguageAndRegister(
                selectedLanguageId.value!,
                selectedDialectId.value!,
              );
            }
          },
        );
      }
    });
  }
}
