import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/widgets/image.dart';

class ScoreDisplayWidget extends StatelessWidget {
  final int score;
  final int totalDatasets;
  final int approvedDatasets;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    required this.totalDatasets,
    required this.approvedDatasets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: assetImageWidget(
                  'score_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            child: Row(
              children: [
                _buildScoreSection(),
                _buildDivider(),
                _buildTotalDatasetSection(),
                _buildDivider(),
                _buildAcceptedDatasetSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return Expanded(
      child: Row(
        children: [
          // Score icon
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: assetSvgImageWidget(
                'score.svg',
                width: 16,
                height: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Score text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2F2E41),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                Text(
                  'profile.score'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6C7278),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDatasetSection() {
    return Expanded(
      child: Row(
        children: [
          // Total dataset icon
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: assetSvgImageWidget(
                'total_dataset.svg',
                width: 14,
                height: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Total dataset text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalDatasets.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2F2E41),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'profile.total_datasets'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6C7278),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedDatasetSection() {
    return Expanded(
      child: Row(
        children: [
          // Accepted dataset icon
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: assetSvgImageWidget(
                'approved_dataset.svg',
                width: 16,
                height: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Accepted dataset text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  approvedDatasets.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2F2E41),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'profile.accepted_datasets'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6C7278),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.1137,
      height: 57,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.15),
          ],
          stops: const [0.2728, 0.4896, 0.7053],
        ),
      ),
    );
  }
}
