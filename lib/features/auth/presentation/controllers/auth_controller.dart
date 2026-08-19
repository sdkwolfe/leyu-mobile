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

  /// Email Registration State
  RxBool isEmailRegistering = false.obs;
  RxString emailRegisterLoadingReason = "".obs;
  
  // Page 0: Credentials
  RxString email = ''.obs;
  RxString password = ''.obs;

  // Page 1: Profile Info
  RxString firstName = ''.obs;
  RxString middleName = ''.obs;
  RxString lastName = ''.obs;
  RxString age = ''.obs; // Replaced birthDate with age
  RxnString gender = RxnString(null);
  Rxn<File> nationalIdFile = Rxn<File>(null);

  // Page 2: Language & Dialect
  RxnString selectedLanguageId = RxnString(null);
  RxSet<LanguageEntity> languages = <LanguageEntity>{}.obs;
  RxBool isLoadingLanguages = false.obs;
  RxnString selectedDialectId = RxnString(null);
  RxSet<DialectEntity> dialects = <DialectEntity>{}.obs;
  RxBool isLoadingDialects = false.obs;

  // Navigation
  RxInt currentPage = 0.obs;

  ///Login
  RxBool isLoggingIn = false.obs;
  RxString loginLoadingReason = "".obs;
  RxString errorMessage = ''.obs;

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
}
