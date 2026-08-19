import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/features/auth/domain/entities/dialect_entity.dart';
import 'package:leyu_mobile/features/auth/domain/entities/language_entity.dart';
import 'package:leyu_mobile/features/auth/domain/usecases/base_data_usecase.dart';
import '../../../../../routes/app_routes.dart';
import '../../domain/usecases/auth_usecase.dart';

class AuthController extends GetxController {
  final AuthUseCase _authUseCase;
  final BaseDataUsecase _baseDataUseCase;

  AuthController(this._authUseCase, this._baseDataUseCase);

  /// Email Registration State (NEW)
  RxBool isEmailRegistering = false.obs;
  RxString emailRegisterLoadingReason = "".obs;
  RxString email = ''.obs;
  RxString password = ''.obs;
  RxString firstName = ''.obs;
  RxString middleName = ''.obs;
  RxString lastName = ''.obs;
  RxString age = ''.obs; 
  RxnString gender = RxnString(null);
  Rxn<File> nationalIdFile = Rxn<File>(null);
  RxnString selectedLanguageId = RxnString(null);
  RxSet<LanguageEntity> languages = <LanguageEntity>{}.obs;
  RxBool isLoadingLanguages = false.obs;
  RxnString selectedDialectId = RxnString(null);
  RxSet<DialectEntity> dialects = <DialectEntity>{}.obs;
  RxBool isLoadingDialects = false.obs;
  RxInt currentPage = 0.obs;

  ///Login
  RxBool isLoggingIn = false.obs;
  RxString loginLoadingReason = "".obs;
  RxString errorMessage = ''.obs;

  /// OLD STATE (Kept as stubs to prevent compilation errors in unused pages)
  RxBool isRegistering = false.obs;
  RxBool isTermsAccepted = false.obs;
  RxString registeredPhone = "".obs;
  RxString registeredPassword = "".obs;
  RxBool isActivatingAccount = false.obs;
  RxString registerLoadingReason = "".obs;
  RxnString verificationId = RxnString(null);
  RxString birthDate = ''.obs;
  RxString referralCode = ''.obs;
  RxBool isRegisteringProfile = false.obs;
  RxString registerProfileLoadingReason = "".obs;
  RxInt forgotPasswordPage = 0.obs;
  RxBool isRequestingOtp = false.obs;
  Rx<String> forgotPhoneNumber = "".obs;
  RxBool isVerifyingOtp = false.obs;
  Rx<String> otp = "".obs;
  RxBool isResettingPassword = false.obs;
  RxString forgotLoadingReason = ''.obs;
  RxBool canResend = true.obs;
  RxInt countdown = 0.obs;
  Timer? _resendTimer;

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  // --- NEW EMAIL REGISTRATION METHODS ---
  Future<void> saveCredentialsAndNext(String emailVal, String passwordVal) async {
    email.value = emailVal;
    password.value = passwordVal;
    currentPage.value = 1;
  }

  Future<void> saveProfileAndNext(String fName, String mName, String lName, String ageVal, String genderValue, File? nationalId) async {
    firstName.value = fName;
    middleName.value = mName;
    lastName.value = lName;
    age.value = ageVal;
    gender.value = genderValue;
    nationalIdFile.value = nationalId;
    currentPage.value = 2;
  }

  Future<void> saveLanguageAndRegister(String languageId, String dialectId) async {
    selectedLanguageId.value = languageId;
    selectedDialectId.value = dialectId;
    
    isEmailRegistering.value = true;
    emailRegisterLoadingReason.value = "Creating Account...";
    
    try {
      await _authUseCase.emailRegister(
        email: email.value,
        password: password.value,
        firstName: firstName.value,
        middleName: middleName.value,
        lastName: lastName.value,
        age: int.parse(age.value),
        gender: gender.value!,
        languageId: languageId,
        dialectId: dialectId,
      );
      showSuccessMessage("Registration successful! Welcome to Leyu.");
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      showErrorMessage("Registration failed: ${e.toString()}");
    } finally {
      isEmailRegistering.value = false;
    }
  }

  Future<void> login(String emailVal, String passwordVal) async {
    isLoggingIn.value = true;
    loginLoadingReason.value = "Logging in";
    await _authUseCase.login(emailVal, passwordVal);
    isLoggingIn.value = false;
  }

  Future<void> getLanguages() async {
    isLoadingLanguages.value = true;
    final result = await _baseDataUseCase.getLanguages();
    languages.value = Set.from(result);
    isLoadingLanguages.value = false;
  }

  Future<void> getDialects(String languageId) async {
    isLoadingDialects.value = true;
    final result = await _baseDataUseCase.getDialects(languageId);
    dialects.value = Set.from(result);
    isLoadingDialects.value = false;
  }

  // --- OLD METHODS (Stubs to fix compilation errors in unused pages) ---
  Future<void> register(String phone, {isActivating = false}) async {}
  Future<void> activateAccount(String otp) async {}
  Future<void> registerProfile() async {}
  Future<void> requestOtp(String phone, {isActivatingAccount = false}) async {}
  Future<void> verifyOtp(String code) async {}
  Future<void> resetPassword(String newPassword) async {}
  
  void saveFirstStage(String fName, String mName, String lName, String bDate, String genderValue, File? nationalId) {
    firstName.value = fName;
    middleName.value = mName;
    lastName.value = lName;
    birthDate.value = bDate;
    gender.value = genderValue;
    nationalIdFile.value = nationalId;
    currentPage.value = 1; 
  }

  void saveThirdStage(String languageId, String dialectId, String emailVal, String referralCodeVal) {
    selectedLanguageId.value = languageId;
    selectedDialectId.value = dialectId;
    email.value = emailVal;
    referralCode.value = referralCodeVal;
    currentPage.value = 3;
  }
}
