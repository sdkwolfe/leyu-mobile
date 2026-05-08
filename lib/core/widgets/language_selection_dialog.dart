import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/localization/localization_controller.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/features/profile/domain/usecases/profile_usecase.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'common.select_language'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            ...LocalizationController.supportedLocales
                .map((localeModel) => Obx(() {
                      final isSelected =
                          localizationController.locale.languageCode ==
                                  localeModel.languageCode &&
                              localizationController.locale.countryCode ==
                                  localeModel.countryCode;

                      return InkWell(
                        onTap: () async {
                          await localizationController.changeLanguage(
                            localeModel.languageCode,
                            localeModel.countryCode,
                          );
                          // Best-effort API update — fire and forget
                          _updateLanguageOnServer(localeModel.languageCode);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localeModel.nativeName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      localeModel.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    })),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'common.cancel'.tr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateLanguageOnServer(String languageCode) {
    try {
      final profileUseCase = Get.find<ProfileUseCase>();
      profileUseCase.updatePreferredLanguage(languageCode);
    } catch (_) {
      // ProfileUseCase may not be registered outside profile context — ignore
    }
  }
}
