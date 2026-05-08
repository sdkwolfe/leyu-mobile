import '../../data/models/dialect.dart';
import '../../data/models/language.dart';

class DialectEntity {
  final String id;
  final String name;
  final List<AlternativeName> alternativeNames;

  DialectEntity({
    required this.id,
    required this.name,
    this.alternativeNames = const [],
  });

  static DialectEntity fromModel(Dialect dialect) {
    return DialectEntity(
      id: dialect.id,
      name: dialect.name,
      alternativeNames: dialect.alternativeNames,
    );
  }

  /// Returns the localized name for [langCode] (e.g. 'am', 'or').
  /// Falls back to [name] if no match is found.
  String localizedName(String langCode) {
    final match = alternativeNames
        .where((alt) => alt.key.toLowerCase() == langCode.toLowerCase())
        .firstOrNull;
    return match?.name ?? name;
  }
}
