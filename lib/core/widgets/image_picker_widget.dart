import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:get/get.dart';

class ImagePickerWidget extends StatelessWidget {
  final String label;
  final String? placeHolder;
  final File? selectedImage;
  final Function(File?) onImageSelected;
  final bool showLabel;
  final bool isOptional;

  const ImagePickerWidget({
    super.key,
    required this.label,
    this.placeHolder,
    required this.selectedImage,
    required this.onImageSelected,
    this.showLabel = true,
    this.isOptional = false,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      showErrorMessage('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionTile(
                  context: context,
                  icon: Icons.photo_camera,
                  title: 'common.take_photo'.tr,
                  subtitle: 'common.take_photo_subtitle'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                _buildOptionTile(
                  context: context,
                  icon: Icons.photo_library,
                  title: 'common.choose_from_gallery'.tr,
                  subtitle: 'common.choose_from_gallery_subtitle'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                if (selectedImage != null)
                  _buildOptionTile(
                    context: context,
                    icon: Icons.delete_outline,
                    title: 'common.remove_image'.tr,
                    subtitle: 'common.remove_image_subtitle'.tr,
                    iconColor: AppColors.red,
                    textColor: AppColors.red,
                    onTap: () {
                      Navigator.pop(context);
                      onImageSelected(null);
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  if (!isOptional)
                    const Text(
                      " *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.red,
                      ),
                    ),
                ],
              ),
            ),
          InkWell(
            onTap: () => _showImageSourceDialog(context),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputBgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selectedImage != null
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: selectedImage != null
                  ? _buildImagePreview()
                  : _buildPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Image.file(
                selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    // This will be handled by the parent InkWell
                  },
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            color: AppColors.inputBgColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'common.image_selected'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'common.tap_to_change'.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.grayText,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            placeHolder ?? 'common.tap_to_upload'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'common.upload_subtitle'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}
