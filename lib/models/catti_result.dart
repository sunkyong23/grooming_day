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

  /// 개발용 디버그 정보
  /// 출시 전 제거 예정
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
