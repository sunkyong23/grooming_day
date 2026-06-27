import 'catti_saved_result.dart';

class CattiMatch {
  final String typeId;
  final int matchPercent;

  const CattiMatch({required this.typeId, required this.matchPercent});

  Map<String, dynamic> toMap() {
    return {'typeId': typeId, 'matchPercent': matchPercent};
  }
}

class CattiResult {
  final String code;

  final Map<String, int> scores;

  final int socialPercent;
  final int curiosityPercent;
  final int activityPercent;
  final int emotionPercent;

  final int answeredCount;
  final int unknownCount;

  final List<CattiMatch> topMatches;

  final Map<String, dynamic> debugInfo;

  const CattiResult({
    required this.code,
    required this.scores,
    required this.socialPercent,
    required this.curiosityPercent,
    required this.activityPercent,
    required this.emotionPercent,
    required this.answeredCount,
    required this.unknownCount,
    required this.topMatches,
    this.debugInfo = const {},
  });

  factory CattiResult.fromSaved(CattiSavedResult saved) {
    return CattiResult(
      code: saved.typeId,
      scores: const {},
      socialPercent: saved.social,
      curiosityPercent: saved.curiosity,
      activityPercent: saved.activity,
      emotionPercent: saved.emotion,
      answeredCount: 20,
      unknownCount: 0,
      topMatches: saved.topMatches.isNotEmpty
          ? saved.topMatches
          : [CattiMatch(typeId: saved.typeId, matchPercent: 100)],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'scores': scores,
      'socialPercent': socialPercent,
      'curiosityPercent': curiosityPercent,
      'activityPercent': activityPercent,
      'emotionPercent': emotionPercent,
      'answeredCount': answeredCount,
      'unknownCount': unknownCount,
      'topMatches': topMatches.map((match) => match.toMap()).toList(),
    };
  }
}
