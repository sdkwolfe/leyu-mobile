import 'language.dart';

class Dialect {
  final String id;
  final String name;
  final List<AlternativeName> alternativeNames;

  Dialect({
    required this.id,
    required this.name,
    this.alternativeNames = const [],
  });

  factory Dialect.fromJson(Map<String, dynamic> json) {
    final rawAlt = json['alternative_names'];
    final altNames = (rawAlt is List)
        ? rawAlt
            .map((e) => AlternativeName.fromJson(e as Map<String, dynamic>))
            .toList()
        : <AlternativeName>[];

    return Dialect(
      id: json['id'] as String,
      name: json['name'] as String,
      alternativeNames: altNames,
    );
  }

  @override
  String toString() => 'Dialect(name: $name)';
}
