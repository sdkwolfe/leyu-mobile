import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/features/auth/data/models/user.dart';

class KycStatusWidget extends StatelessWidget {
  final KycStatus? kycStatus;
  final VoidCallback onUpload;

  const KycStatusWidget({
    super.key,
    required this.kycStatus,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (kycStatus == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(_getIcon(), color: _getIconColor(), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile.kyc_verification'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F2E41),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getDescriptionText(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6C7278),
                height: 1.4,
              ),
            ),
            // Show upload button for pending (no ID yet) and rejected
            if (kycStatus == KycStatus.pending ||
                kycStatus == KycStatus.rejected) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    kycStatus == KycStatus.pending
                        ? 'profile.kyc_upload'.tr
                        : 'profile.kyc_reupload'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (kycStatus) {
      case KycStatus.pending:
        return AppColors.red.withValues(alpha: 0.05);
      case KycStatus.underReview:
        return AppColors.yellow.withValues(alpha: 0.05);
      case KycStatus.approved:
        return AppColors.green.withValues(alpha: 0.05);
      case KycStatus.rejected:
        return AppColors.red.withValues(alpha: 0.05);
      default:
        return Colors.grey.withValues(alpha: 0.05);
    }
  }

  Color _getBorderColor() {
    switch (kycStatus) {
      case KycStatus.pending:
        return AppColors.red.withValues(alpha: 0.2);
      case KycStatus.underReview:
        return AppColors.yellow.withValues(alpha: 0.2);
      case KycStatus.approved:
        return AppColors.green.withValues(alpha: 0.2);
      case KycStatus.rejected:
        return AppColors.red.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  Color _getIconBackgroundColor() {
    switch (kycStatus) {
      case KycStatus.pending:
        return AppColors.red.withValues(alpha: 0.15);
      case KycStatus.underReview:
        return AppColors.yellow.withValues(alpha: 0.15);
      case KycStatus.approved:
        return AppColors.green.withValues(alpha: 0.15);
      case KycStatus.rejected:
        return AppColors.red.withValues(alpha: 0.15);
      default:
        return Colors.grey.withValues(alpha: 0.15);
    }
  }

  Color _getIconColor() {
    switch (kycStatus) {
      case KycStatus.pending:
        return AppColors.red;
      case KycStatus.underReview:
        return AppColors.yellow;
      case KycStatus.approved:
        return AppColors.green;
      case KycStatus.rejected:
        return AppColors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (kycStatus) {
      case KycStatus.pending:
        return AppColors.red;
      case KycStatus.underReview:
        return AppColors.yellow;
      case KycStatus.approved:
        return AppColors.green;
      case KycStatus.rejected:
        return AppColors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (kycStatus) {
      case KycStatus.pending:
        return Icons.upload_file_rounded;
      case KycStatus.underReview:
        return Icons.schedule_rounded;
      case KycStatus.approved:
        return Icons.check_circle_rounded;
      case KycStatus.rejected:
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusText() {
    switch (kycStatus) {
      case KycStatus.pending:
        return 'profile.kyc_status_pending'.tr;
      case KycStatus.underReview:
        return 'profile.kyc_status_under_review'.tr;
      case KycStatus.approved:
        return 'profile.kyc_status_approved'.tr;
      case KycStatus.rejected:
        return 'profile.kyc_status_rejected'.tr;
      default:
        return '';
    }
  }

  String _getDescriptionText() {
    switch (kycStatus) {
      case KycStatus.pending:
        return 'profile.kyc_desc_pending'.tr;
      case KycStatus.underReview:
        return 'profile.kyc_desc_under_review'.tr;
      case KycStatus.approved:
        return 'profile.kyc_desc_approved'.tr;
      case KycStatus.rejected:
        return 'profile.kyc_desc_rejected'.tr;
      default:
        return '';
    }
  }
}
