import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/services/onesignal_service.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/core/cache/local_storage.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/widgets/image_picker_widget.dart';
import 'package:leyu_mobile/features/home/presentation/controllers/home_controller.dart';
import 'package:leyu_mobile/features/profile/domain/usecases/profile_usecase.dart';
import 'package:leyu_mobile/features/auth/data/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final LocalStorage _localStorage;
  final ProfileUseCase _profileUseCase;

  ProfileController(this._localStorage, this._profileUseCase);

  // Profile Data
  RxBool isLoadingProfile = false.obs;
  RxString profileName = ''.obs;
  RxString profileEmail = ''.obs;
  RxString profileStatus = 'Active'.obs;
  RxString profileImage = ''.obs;
  RxString profilePhone = ''.obs;
  RxBool isEditingProfile = false.obs;

  // Additional Profile Data (Read-only)
  RxString profileGender = ''.obs;
  RxString profileBirthDate = ''.obs;
  RxString profileLanguage = ''.obs;
  RxString profileDialect = ''.obs;

  // Score and Dataset Data
  RxInt profileScore = 0.obs;
  RxInt totalDatasetCount = 0.obs;
  RxInt approvedDatasetCount = 0.obs;

  // KYC Status
  Rxn<KycStatus> kycStatus = Rxn<KycStatus>(null);
  RxBool isUploadingNationalId = false.obs;

  // Referral
  RxBool isReferred = true.obs;
  RxBool isApplyingReferral = false.obs;
  final TextEditingController referralController = TextEditingController();

  // Form Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Read-only Form Controllers
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController dialectController = TextEditingController();

  // Profile Picture Upload
  final ImagePicker _imagePicker = ImagePicker();
  RxBool isUploadingProfilePicture = false.obs;

  // Change Password
  RxBool isChangingPassword = false.obs;

  HomeController get _homeController => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      isLoadingProfile.value = true;
      User? user = await _profileUseCase.getUserProfile();
      if (user != null) {
        profileName.value =
            '${user.firstName?.capitalizeFirst ?? ''} ${user.middleName?.capitalizeFirst ?? ''} ${user.lastName?.capitalizeFirst ?? ''}'
                .trim();
        profileEmail.value = user.email ?? '';
        profilePhone.value = user.phoneNumber ?? '';
        profileImage.value = user.profilePicture ?? '';
        profileStatus.value = (user.isActive ?? true) ? 'Active' : 'Inactive';

        // Load additional read-only fields
        profileGender.value = user.gender ?? '';
        profileBirthDate.value = user.birthDate ?? '';
        profileLanguage.value = user.language?.name ?? '';
        profileDialect.value = user.dialect?.name ?? '';

        // Load score and dataset data
        profileScore.value = user.score ?? 0;
        totalDatasetCount.value = user.totalDatasetCount ?? 0;
        approvedDatasetCount.value = user.approvedDatasetCount ?? 0;

        // Load KYC status
        kycStatus.value = user.kycStatus;

        // Load referral status
        isReferred.value = user.referred ?? true;

        // Initialize form controllers with user data
        _initializeControllers();
      }
    } catch (e) {
      e.printError();
      print('Error loading user profile: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void _initializeControllers() {
    // Split the full name into individual fields
    final nameParts = profileName.value.split(' ');
    firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    middleNameController.text = nameParts.length > 1 ? nameParts[1] : '';
    lastNameController.text =
        nameParts.length > 2 ? nameParts.sublist(2).join(' ') : '';

    emailController.text = profileEmail.value;

    // Initialize read-only controllers
    phoneNumberController.text = profilePhone.value.substring(4);
    genderController.text = profileGender.value == 'Male'
        ? 'auth.profile.gender_male'.tr
        : profileGender.value == 'Female'
            ? 'auth.profile.gender_female'.tr
            : profileGender.value;
    birthDateController.text = profileBirthDate.value;
    languageController.text = profileLanguage.value;
    dialectController.text = profileDialect.value;
  }

  Future<void> pickAndUploadProfilePicture() async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        isUploadingProfilePicture.value = true;
        String? profilePicture =
            await _profileUseCase.uploadProfilePicture(image.path);
        if (profilePicture != null) {
          profileImage.value = profilePicture;
          _homeController.userProfilePic.value = profilePicture;
          showSuccessMessage('Profile picture updated successfully');
        }
        isUploadingProfilePicture.value = false;
      }
    } catch (e) {
      isUploadingProfilePicture.value = false;
      showErrorMessage('Failed to upload profile picture');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'common.select_image_source'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSourceTile(
                icon: Icons.photo_camera,
                title: 'common.take_photo'.tr,
                subtitle: 'common.take_photo_subtitle'.tr,
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              _buildSourceTile(
                icon: Icons.photo_library,
                title: 'common.choose_from_gallery'.tr,
                subtitle: 'common.choose_from_gallery_subtitle'.tr,
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.grayText)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    try {
      // Prepare profile data for API
      final profileData = {
        'first_name': firstNameController.text,
        'middle_name': middleNameController.text,
        'last_name': lastNameController.text,
        'email': emailController.text,
      };
      isEditingProfile.value = true;
      final success = await _profileUseCase.updateUserProfile(profileData);
      isEditingProfile.value = false;
      if (success) {
        profileName.value =
            '${firstNameController.text} ${middleNameController.text} ${lastNameController.text}'
                .trim();
        profileEmail.value = emailController.text;
        _localStorage.updateUserName(
            firstName: firstNameController.text,
            middleName: middleNameController.text,
            lastName: lastNameController.text);
        _homeController.userFirstName.value = firstNameController.text;
        _homeController.userMiddleName.value = middleNameController.text;
        Get.back();
        showSuccessMessage('Profile updated successfully');
      } else {
        showErrorMessage('Failed to update profile');
      }
    } catch (e) {
      isEditingProfile.value = false;
      showErrorMessage('Failed to update profile');
    }
  }

  void cancelEdit() {
    _initializeControllers();
    Get.back();
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      isChangingPassword.value = true;
      final success =
          await _profileUseCase.changePassword(currentPassword, newPassword);
      isChangingPassword.value = false;
      if (success) {
        Get.back();
        showSuccessMessage('Password changed successfully');
      } else {
        showErrorMessage('Failed to change password');
      }
    } catch (e) {
      isChangingPassword.value = false;
      showErrorMessage('Failed to change password');
    }
  }

  void showNationalIdUploadSheet() {
    final Rxn<File> selectedNationalId = Rxn<File>(null);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'profile.kyc_reupload_title'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F2E41),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'profile.kyc_reupload_subtitle'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6C7278),
              ),
            ),
            const SizedBox(height: 20),
            // Image picker
            Obx(() => ImagePickerWidget(
                  label: "auth.profile.national_id".tr,
                  placeHolder: "auth.profile.national_id_placeholder".tr,
                  selectedImage: selectedNationalId.value,
                  onImageSelected: (File? file) {
                    selectedNationalId.value = file;
                  },
                  showLabel: true,
                  isOptional: false,
                )),
            const SizedBox(height: 20),
            // Upload button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedNationalId.value != null &&
                            !isUploadingNationalId.value
                        ? () => uploadNationalId(selectedNationalId.value!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: AppColors.gray,
                    ),
                    child: isUploadingNationalId.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'profile.kyc_upload_button'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  Future<void> uploadNationalId(File nationalIdFile) async {
    try {
      isUploadingNationalId.value = true;
      final success =
          await _profileUseCase.uploadNationalId(nationalIdFile.path);
      isUploadingNationalId.value = false;
      if (success) {
        Get.back();
        kycStatus.value = KycStatus.underReview;
        showSuccessMessage('profile.kyc_upload_success'.tr);
      } else {
        showErrorMessage('profile.kyc_upload_failed'.tr);
      }
    } catch (e) {
      isUploadingNationalId.value = false;
      showErrorMessage('profile.kyc_upload_failed'.tr);
    }
  }

  void showReferralSheet() {
    referralController.clear();
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'profile.referral_title'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F2E41),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'profile.referral_subtitle'.tr,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7278),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: referralController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'profile.referral_placeholder'.tr,
                hintStyle:
                    const TextStyle(color: AppColors.grayText, fontSize: 14),
                filled: true,
                fillColor: AppColors.inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isApplyingReferral.value
                        ? null
                        : () => _submitReferralCode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: AppColors.gray,
                    ),
                    child: isApplyingReferral.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'profile.referral_apply'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> _submitReferralCode() async {
    final code = referralController.text.trim();
    if (code.isEmpty) {
      showErrorMessage('profile.referral_required'.tr);
      return;
    }
    isApplyingReferral.value = true;
    final success = await _profileUseCase.applyReferralCode(code);
    isApplyingReferral.value = false;
    if (success) {
      isReferred.value = true;
      Get.back();
      showSuccessMessage('profile.referral_success'.tr);
    }
  }

  void logout() async {
    // Logout from OneSignal
    await OneSignalService.logoutUser();

    // Clear local storage
    _localStorage.clearStorage();

    // Navigate to login
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    genderController.dispose();
    birthDateController.dispose();
    languageController.dispose();
    dialectController.dispose();
    referralController.dispose();
    super.onClose();
  }
}
