import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/utils/screen_size.dart';
import 'package:leyu_mobile/core/widgets/image.dart';
import 'package:leyu_mobile/core/widgets/loading.dart';
import 'package:leyu_mobile/core/widgets/language_selection_dialog.dart';
import 'package:leyu_mobile/features/profile/presentation/widgets/score_display_widget.dart';
import 'package:leyu_mobile/features/profile/presentation/widgets/kyc_status_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileMainWidget extends StatelessWidget {
  const ProfileMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(controller),
            const SizedBox(height: 30),
            // Profile Options Section
            _buildProfileOptionsSection(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(ProfileController controller) {
    return Obx(() => controller.isLoadingProfile.value
        ? SizedBox(
            height: getScreenHeight(Get.context!) * 0.2,
            child: Center(
                child: LoadingWidget(
              size: 40,
              isTransparent: true,
              reason: 'profile.loading_profile'.tr,
            )),
          )
        : Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: ClipOval(
                      child: controller.profileImage.value.isNotEmpty
                          ? Image.network(
                              controller.profileImage.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultProfileImage(),
                            )
                          : _buildDefaultProfileImage(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: controller.pickAndUploadProfilePicture,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child:
                            Obx(() => controller.isUploadingProfilePicture.value
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.white,
                                    size: 15,
                                  )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Profile Name
              Obx(() => Text(
                    // show only first and last name
                    controller.profileName.value.split(' ')[0] +
                        (controller.profileName.value.split(' ').length > 1
                            ? ' ${controller.profileName.value.split(' ')[1]}'
                            : ''),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 10),

              // Status Badge
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.profileStatus.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),

              // Score Display
              Obx(() => ScoreDisplayWidget(
                    score: controller.profileScore.value,
                    totalDatasets: controller.totalDatasetCount.value,
                    approvedDatasets: controller.approvedDatasetCount.value,
                  )),

              // KYC Status
              Obx(() => KycStatusWidget(
                    kycStatus: controller.kycStatus.value,
                    onUpload: controller.showNationalIdUploadSheet,
                  )),

              // Referral Banner
              Obx(() => !controller.isReferred.value
                  ? _buildReferralBanner(controller)
                  : const SizedBox.shrink()),
            ],
          ));
  }

  Widget _buildReferralBanner(ProfileController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.referral_banner_title'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F2E41),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'profile.referral_banner_subtitle'.tr,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6C7278)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: controller.showReferralSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'profile.referral_apply'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      color: AppColors.lightBlue,
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildProfileOptionsSection(
      BuildContext context, ProfileController controller) {
    final List<Map<String, dynamic>> options = [
      {
        'icon': 'edit.svg',
        'title': 'profile.edit'.tr,
        'onTap': () => _navigateToEditProfile(context),
      },
      {
        'icon': 'language.svg',
        'title': 'profile.language'.tr,
        'onTap': () => _navigateToLanguage(context),
      },
      {
        'icon': 'help.svg',
        'title': 'profile.help'.tr,
        'onTap': () => _navigateToHelp(context),
      },
      {
        'icon': 'security.svg',
        'title': 'profile.privacy_security'.tr,
        'onTap': () => _navigateToPrivacy(context),
      },
      {
        'icon': 'logout.svg',
        'title': 'profile.logout'.tr,
        'onTap': () => _logout(context, controller),
        'isDestructive': true,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: options
            .map((option) => _buildOptionItem(
                  icon: option['icon'],
                  title: option['title'],
                  onTap: option['onTap'],
                  isDestructive: option['isDestructive'] ?? false,
                  // add bottom margin for first, item before last and last item
                  bottomMargin: (option == options.first ||
                          option == options[options.length - 2] ||
                          option == options.last)
                      ? 15
                      : 0,
                  topBorderRadius: option == options[0] ||
                          option == options[1] ||
                          option == options[options.length - 1]
                      ? 20
                      : 0,
                  bottomBorderRadius: option == options[options.length - 1] ||
                          option == options[options.length - 2] ||
                          option == options[0]
                      ? 20
                      : 0,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildOptionItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    double bottomMargin = 0,
    double topBorderRadius = 0,
    double bottomBorderRadius = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: bottomMargin == 0
                ? const Border(
                    bottom: BorderSide(
                      color: AppColors.gray,
                      width: 1,
                    ),
                  )
                : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topBorderRadius),
              topRight: Radius.circular(topBorderRadius),
              bottomLeft: Radius.circular(bottomBorderRadius),
              bottomRight: Radius.circular(bottomBorderRadius),
            ),
          ),
          child: Row(
            children: [
              assetSvgImageWidget(icon,
                  width: 20,
                  height: 20,
                  color: isDestructive ? AppColors.red : AppColors.darkGray),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppColors.red : AppColors.darkGray,
                  ),
                ),
              ),
              const Icon(
                Icons.navigate_next,
                color: Colors.black,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Navigate to edit profile page
    Get.toNamed('/editProfile');
  }

  void _navigateToLanguage(BuildContext context) {
    // Show language selection dialog
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }

  void _navigateToHelp(BuildContext context) {
    // Navigate to help page
    Get.toNamed('/chatbot');
  }

  void _navigateToPrivacy(BuildContext context) {
    // Navigate to privacy and security page
    Get.toNamed('/changePassword');
  }

  void _logout(BuildContext context, ProfileController controller) {
    // Show logout confirmation dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.darkGray, width: 1)),
        title: Text('profile.logout_title'.tr),
        content: Text('profile.logout_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common.cancel'.tr,
                style: const TextStyle(color: AppColors.darkGray)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text('profile.logout_button'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
