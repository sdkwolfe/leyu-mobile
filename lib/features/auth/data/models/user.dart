import 'package:leyu_mobile/features/auth/data/models/dialect.dart';
import 'package:leyu_mobile/features/auth/data/models/language.dart';

class User {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? gender;
  final int? age;
  final bool? isActive;
  final String? roleId;
  final Role? role;
  final Language? language;
  final Dialect? dialect;
  final int? score;
  final KycStatus? kycStatus;
  final int? totalDatasetCount;
  final int? approvedDatasetCount;
  final bool? referred;

  User({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.gender,
    this.age,
    this.isActive,
    this.roleId,
    this.role,
    this.language,
    this.dialect,
    this.score,
    this.kycStatus,
    this.totalDatasetCount,
    this.approvedDatasetCount,
    this.referred,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      gender: json['gender'],
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      isActive: json['is_active'],
      roleId: json['role_id'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      language:
          json['language'] != null ? Language.fromJson(json['language']) : null,
      dialect:
          json['dialect'] != null ? Dialect.fromJson(json['dialect']) : null,
      score: json['score'],
      kycStatus: json['kyc_verification_status'] != null
          ? KycStatus.fromString(json['kyc_verification_status'])
          : null,
      totalDatasetCount: json['totalDataSetSubmitted'],
      approvedDatasetCount: json['totalApprovedDataSetSubmitted'],
      referred: json['referred'] == true || json['referred'] == 1,
    );
  }
}

class Role {
  final String? id;
  final String? name;

  Role({
    this.id,
    this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }
}

enum KycStatus {
  pending,
  approved,
  rejected,
  underReview;

  static fromString(String status) {
    switch (status) {
      case 'pending':
        return KycStatus.pending;
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      case 'under_review':
        return KycStatus.underReview;
      default:
        throw ArgumentError('Invalid KYC status: $status');
    }
  }
}
