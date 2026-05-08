import 'package:leyu_mobile/features/auth/data/models/user.dart';

class UserEntity {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String gender;
  final bool isActive;
  final String role;
  final int? score;
  final KycStatus? kycStatus;
  final int? totalDatasetCount;
  final int? approvedDatasetCount;

  UserEntity({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.gender,
    required this.isActive,
    required this.role,
    this.score,
    this.kycStatus,
    this.totalDatasetCount,
    this.approvedDatasetCount,
  });

  static UserEntity fromModel(User user){
    return UserEntity(
      id: user.id ?? '',
      firstName: user.firstName ?? '',
      middleName: user.middleName ?? '',
      lastName: user.lastName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      profilePicture: user.profilePicture,
      gender: user.gender ?? 'N/A',
      isActive: user.isActive ?? false,
      role: user.role?.name ?? 'N/A',
      score: user.score,
      kycStatus: user.kycStatus,
      totalDatasetCount: user.totalDatasetCount,
      approvedDatasetCount: user.approvedDatasetCount,
    );
  }
}