import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/widgets/language_changer.dart';

import '../../../../core/utils/screen_size.dart';
import '../../../../core/widgets/button.dart';
// Removed: import '../../../../core/widgets/date_picker.dart';
import '../../../../core/widgets/dropdown.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../../core/widgets/image_picker_widget.dart';
import '../controllers/auth_controller.dart';

class RegisterUserInfoWidget extends StatefulWidget {
  RegisterUserInfoWidget({super.key});

  @override
  State<RegisterUserInfoWidget> createState() => _RegisterUserInfoWidgetState();
}

class _RegisterUserInfoWidgetState extends State<RegisterUserInfoWidget> {
  final AuthController _authController = Get.find();

  final List<String> genderOptions = ['Male', 'Female'];

  final formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  RxnString selectedGender = RxnString(null);
  Rxn<File> selectedNationalId = Rxn<File>(null);

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _middleNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstNameController.value =
        TextEditingValue(text: _authController.firstName.value);
    _middleNameController.value =
        TextEditingValue(text: _authController.middleName.value);
    _lastNameController.value =
        TextEditingValue(text: _authController.lastName.value);
        
    // Safely handle age whether it's stored as String or Int in the controller
    _ageController.value =
        TextEditingValue(text: _authController.age.value.toString());
        
    selectedGender.value = _authController.gender.value;
    selectedNationalId.value = _authController.nationalIdFile.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: getScreenHeight(context) * 0.025,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Icons.arrow_back, size: 26),
                    ),
                    const Spacer(),
                    LanguageChanger()
                  ],
                ),
                SizedBox(height: getScreenHeight(context) * 0.025),
                Text(
                  "auth.profile.user_info_title".tr,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  "auth.profile.user_info_subtitle".tr,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                SizedBox(height: getScreenHeight(context) * 0.02),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      InputBoxWidget(
                        inputType: InputType.text,
                        label: "auth.profile.first_name".tr,
                        placeHolder: "auth.profile.first_name_placeholder".tr,
                        controller: _firstNameController,
                        focus: _firstNameFocusNode,
                        focusNext: _middleNameFocusNode,
                        showLabel: true,
                      ),
                      SizedBox(height: getScreenHeight(context) * 0.01),
                      InputBoxWidget(
                        inputType: InputType.text,
                        label: "auth.profile.middle_name".tr,
                        placeHolder: "auth.profile.middle_name_placeholder".tr,
                        controller: _middleNameController,
                        focus: _middleNameFocusNode,
                        focusNext: _lastNameFocusNode,
                        showLabel: true,
                      ),
                      SizedBox(height: getScreenHeight(context) * 0.01),
                      InputBoxWidget(
                        inputType: InputType.text,
                        label: "auth.profile.last_name".tr,
                        placeHolder: "auth.profile.last_name_placeholder".tr,
                        controller: _lastNameController,
                        focus: _lastNameFocusNode,
                        focusNext: _ageFocusNode,
                        showLabel: true,
                      ),
                      SizedBox(height: getScreenHeight(context) * 0.01),
                      
                      // AGE INPUT (Replaces DatePicker)
                      InputBoxWidget(
                        inputType: InputType.number, // Fallback to InputType.text if .number doesn't exist in your enum
                        label: "Age", 
                        placeHolder: "12 - 120",
                        controller: _ageController,
                        focus: _ageFocusNode,
                        focusNext: null,
                        showLabel: true,
                      ),
                      
                      SizedBox(height: getScreenHeight(context) * 0.01),
                      DropdownBoxWidget<String>(
                        label: "auth.profile.gender".tr,
                        items: genderOptions,
                        selectedItem: selectedGender.value,
                        showLabel: true,
                        isOptional: false,
                        placeHolder: "auth.profile.gender_placeholder".tr,
                        displayText: (String text) {
                          return text == 'Male'
                              ? "auth.profile.gender_male".tr
                              : "auth.profile.gender_female".tr;
                        },
                        onChanged: (String? value) {
                          if (value != null) {
                            selectedGender.value = value;
                          } else {
                            selectedGender.value = null;
                          }
                        },
                      ),
                      SizedBox(height: getScreenHeight(context) * 0.01),
                      Obx(() => ImagePickerWidget(
                            label: "auth.profile.national_id".tr,
                            placeHolder:
                                "auth.profile.national_id_placeholder".tr,
                            selectedImage: selectedNationalId.value,
                            onImageSelected: (File? file) {
                              selectedNationalId.value = file;
                            },
                            showLabel: true,
                            isOptional: true,
                          )),
                      SizedBox(height: getScreenHeight(context) * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ButtonWidget(
          text: "Continue".tr,
          loadingText: "Continuing".tr,
          fontSize: 16,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final ageStr = _ageController.value.text.trim();
              final age = int.tryParse(ageStr);
              
              // Strict Validation: Integer only, no decimals, no negatives, 12 <= age <= 120
              if (age == null || age < 12 || age > 120) {
                Get.snackbar(
                  "Invalid Age", 
                  "Age must be a whole number between 12 and 120.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              _authController.saveFirstStage(
                _firstNameController.value.text.trim(),
                _middleNameController.value.text.trim(),
                _lastNameController.value.text.trim(),
                ageStr, // Pass age string instead of birth_date
                selectedGender.value!,
                selectedNationalId.value,
              );
            }
          },
        ),
        SizedBox(height: getScreenHeight(context) * 0.025),
      ],
    );
  }
}
