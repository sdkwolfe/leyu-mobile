class NewUser {
  String firstName;
  String middleName;
  String lastName;
  String birthDate;
  String gender;
  String languageId;
  String dialectId;
  String email;
  String password;
  String? referralCode;
  String? nationalIdPath;

  NewUser({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.languageId,
    required this.dialectId,
    required this.email,
    required this.password,
    this.referralCode,
    this.nationalIdPath,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'birth_date': birthDate,
      'gender': gender,
      'dialect_id': dialectId,
      'language_id': languageId,
    };

    // Only include referral_code if it's not null and not empty
    if (referralCode != null && referralCode!.isNotEmpty) {
      data['referral_code'] = referralCode;
    }

    return data;
  }
}
