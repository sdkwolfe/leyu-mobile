class BankModel {
  final int id;
  final String slug;
  final String swift;
  final String name;
  final int acctLength;
  final bool isMobileMoney;
  final bool isActive;

  BankModel({
    required this.id,
    required this.slug,
    required this.swift,
    required this.name,
    required this.acctLength,
    required this.isMobileMoney,
    required this.isActive,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] as int,
      slug: json['slug'] as String,
      swift: json['swift'] as String,
      name: json['name'] as String,
      acctLength: json['acct_length'] as int,
      isMobileMoney:
          json['is_mobilemoney'] == 1 || json['is_mobilemoney'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
