import 'catti_question.dart';

class CattiTypeProfile {
  final String id;
  final String emoji;
  final String name;
  final String keyword;
  final String title;
  final String description;

  final int targetSocial;
  final int targetCuriosity;
  final int targetActivity;
  final int targetEmotion;

  final List<CattiTrait> coreTraits;
  final List<CattiTrait> bonusTraits;

  final List<String> traits;
  final List<String> tips;

  const CattiTypeProfile({
    required this.id,
    required this.emoji,
    required this.name,
    required this.keyword,
    required this.title,
    required this.description,
    required this.targetSocial,
    required this.targetCuriosity,
    required this.targetActivity,
    required this.targetEmotion,
    this.coreTraits = const [],
    this.bonusTraits = const [],
    required this.traits,
    required this.tips,
  });
}
