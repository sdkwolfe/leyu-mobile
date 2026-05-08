class Language {
  final String id;
  final String code;
  final String name;
  final List<AlternativeName> alternativeNames;

  Language({
    required this.id,
    required this.code,
    required this.name,
    this.alternativeNames = const [],
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    final rawAlt = json['alternative_names'];
    final altNames = (rawAlt is List)
        ? rawAlt
            .map((e) => AlternativeName.fromJson(e as Map<String, dynamic>))
            .toList()
        : <AlternativeName>[];

    return Language(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      alternativeNames: altNames,
    );
  }

  @override
  String toString() => 'Language(code: $code, name: $name)';
}

class AlternativeName {
  final String key;
  final String name;

  const AlternativeName({required this.key, required this.name});

  factory AlternativeName.fromJson(Map<String, dynamic> json) {
    return AlternativeName(
      key: json['key'] as String,
      name: json['name'] as String,
    );
  }
}
