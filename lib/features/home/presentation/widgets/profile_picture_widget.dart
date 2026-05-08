import 'package:flutter/material.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final double size;
  final String? firstName;
  final String? lastName;

  const ProfilePictureWidget(
      {this.profilePictureUrl,
      this.size = 35.0,
      this.firstName,
      this.lastName,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: profilePictureUrl != null
            ? Image.network(
                profilePictureUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size / 3,
                      height: size / 3,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAvatar();
                },
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          '${firstName?.substring(0, 1) ?? ''}${lastName?.substring(0, 1) ?? ''}',
          style: TextStyle(fontSize: size / 2.2, color: Colors.white),
        ),
      ),
    );
  }
}
