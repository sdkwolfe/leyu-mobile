import '../../data/models/language.dart';

class LanguageEntity {
  final String id;
  final String code;
  final String name;
  final List<AlternativeName> alternativeNames;

  LanguageEntity({
    required this.id,
    required this.code,
    required this.name,
    this.alternativeNames = const [],
  });

  static LanguageEntity fromModel(Language language) {
    return LanguageEntity(
      id: language.id,
      code: language.code,
      name: language.name,
      alternativeNames: language.alternativeNames,
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
