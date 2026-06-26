import 'dart:math';

import '../data/catti_questions.dart';
import '../data/catti_type_profiles.dart';
import '../models/catti_question.dart';
import '../models/catti_result.dart';
import '../models/catti_type_profile.dart';

class CattiService {
  CattiResult calculateResult(Map<String, CattiOption> answers) {
    double socialRaw = 0;
    double curiosityRaw = 0;
    double activityRaw = 0;
    double emotionRaw = 0;

    double socialMax = 0;
    double curiosityMax = 0;
    double activityMax = 0;
    double emotionMax = 0;

    final traitScores = <CattiTrait, int>{};

    int answeredCount = 0;
    int unknownCount = 0;

    for (final question in cattiQuestions) {
      final option = answers[question.id];
      if (option == null) continue;

      _addPossibleMaxScores(
        question: question,
        onSocial: (value) => socialMax += value,
        onCuriosity: (value) => curiosityMax += value,
        onActivity: (value) => activityMax += value,
        onEmotion: (value) => emotionMax += value,
      );

      if (option.scores.isEmpty) {
        unknownCount++;
        continue;
      }

      answeredCount++;

      for (final score in option.scores) {
        final weightedValue = score.value * question.weight;

        switch (score.axis) {
          case CattiAxis.social:
            socialRaw += weightedValue;
            break;
          case CattiAxis.curiosity:
            curiosityRaw += weightedValue;
            break;
          case CattiAxis.activity:
            activityRaw += weightedValue;
            break;
          case CattiAxis.emotion:
            emotionRaw += weightedValue;
            break;
        }
      }

      for (final traitScore in option.traits) {
        final weightedTraitValue = (traitScore.value * question.weight).round();

        traitScores.update(
          traitScore.trait,
          (current) => current + weightedTraitValue,
          ifAbsent: () => weightedTraitValue,
        );
      }
    }

    final socialPercent = _rawToPercent(socialRaw, socialMax);
    final curiosityPercent = _rawToPercent(curiosityRaw, curiosityMax);
    final activityPercent = _rawToPercent(activityRaw, activityMax);
    final emotionPercent = _rawToPercent(emotionRaw, emotionMax);

    final matchResult = findTopMatches(
      socialPercent: socialPercent,
      curiosityPercent: curiosityPercent,
      activityPercent: activityPercent,
      emotionPercent: emotionPercent,
      traitScores: traitScores,
      tieBreakerType: _getTieBreakerType(answers),
    );

    return CattiResult(
      code: matchResult.matches.first.typeId,
      scores: {
        'socialRaw': socialRaw.round(),
        'curiosityRaw': curiosityRaw.round(),
        'activityRaw': activityRaw.round(),
        'emotionRaw': emotionRaw.round(),
      },
      socialPercent: socialPercent,
      curiosityPercent: curiosityPercent,
      activityPercent: activityPercent,
      emotionPercent: emotionPercent,
      answeredCount: answeredCount,
      unknownCount: unknownCount,
      topMatches: matchResult.matches,
      debugInfo: {
        'traitScores': traitScores.map(
          (trait, value) => MapEntry(trait.name, value),
        ),
        'candidateScores': matchResult.debug,
      },
    );
  }

  CattiTypeProfile findClosestProfile({
    required int socialPercent,
    required int curiosityPercent,
    required int activityPercent,
    required int emotionPercent,
    Map<CattiTrait, int> traitScores = const {},
    String? tieBreakerType,
  }) {
    final result = findTopMatches(
      socialPercent: socialPercent,
      curiosityPercent: curiosityPercent,
      activityPercent: activityPercent,
      emotionPercent: emotionPercent,
      traitScores: traitScores,
      tieBreakerType: tieBreakerType,
    );

    return cattiTypeProfiles.firstWhere(
      (profile) => profile.id == result.matches.first.typeId,
    );
  }

  TopMatchResult findTopMatches({
    required int socialPercent,
    required int curiosityPercent,
    required int activityPercent,
    required int emotionPercent,
    required Map<CattiTrait, int> traitScores,
    String? tieBreakerType,
  }) {
    final candidates = cattiTypeProfiles.map((profile) {
      final distance = _distance(
        socialPercent,
        curiosityPercent,
        activityPercent,
        emotionPercent,
        profile.targetSocial,
        profile.targetCuriosity,
        profile.targetActivity,
        profile.targetEmotion,
      );

      final traitFitScore = _calculateTraitFitScore(
        profile: profile,
        traitScores: traitScores,
      );

      final axisScore = _distanceToAxisScore(distance);

      final tieBreakerScore = _getTieBreakerBonus(
        profile: profile,
        tieBreakerType: tieBreakerType,
      );

      // 핵심 구조:
      // Trait가 후보를 만들고, 4축 점수는 보정만 한다.
      final finalScore = traitFitScore + axisScore + tieBreakerScore;

      return _ProfileCandidate(
        profile: profile,
        distance: distance,
        baseScore: axisScore,
        traitScore: traitFitScore,
        tieBreakerScore: tieBreakerScore,
        finalScore: finalScore,
      );
    }).toList();

    candidates.sort((a, b) => b.finalScore.compareTo(a.finalScore));

    final matches = candidates.take(3).map((candidate) {
      return CattiMatch(
        typeId: candidate.profile.id,
        matchPercent: candidate.finalScore.round().clamp(0, 100),
      );
    }).toList();

    final debug = candidates.take(5).map((candidate) {
      return {
        'typeId': candidate.profile.id,
        'distance': candidate.distance.toStringAsFixed(1),
        'axisScore': candidate.baseScore.toStringAsFixed(1),
        'traitFitScore': candidate.traitScore.toStringAsFixed(1),
        'tieBreakerScore': candidate.tieBreakerScore.toStringAsFixed(1),
        'finalScore': candidate.finalScore.toStringAsFixed(1),
      };
    }).toList();

    return TopMatchResult(matches: matches, debug: debug);
  }

  double _distanceToAxisScore(double distance) {
    const maxDistance = 140.0;
    final normalized = 1 - (distance / maxDistance);

    // 4축은 최종 타입 결정의 보조 역할만 한다.
    return (normalized * 25).clamp(0, 25);
  }

  double _calculateTraitFitScore({
    required CattiTypeProfile profile,
    required Map<CattiTrait, int> traitScores,
  }) {
    double coreScore = 0;
    double bonusScore = 0;
    int matchedCoreCount = 0;

    for (final trait in profile.coreTraits) {
      final value = traitScores[trait] ?? 0;

      coreScore += value;

      if (value >= 7) {
        matchedCoreCount++;
      }
    }

    for (final trait in profile.bonusTraits) {
      final value = traitScores[trait] ?? 0;
      bonusScore += value;
    }

    final coreAverage = profile.coreTraits.isEmpty
        ? 0.0
        : coreScore / profile.coreTraits.length;

    final bonusAverage = profile.bonusTraits.isEmpty
        ? 0.0
        : bonusScore / profile.bonusTraits.length;

    // Core 평균 중심. Bonus는 약하게만 반영.
    var fitScore = (coreAverage * 3.1) + (bonusAverage * 0.9);

    // Core trait 여러 개가 동시에 맞으면 타입성 강화.
    fitScore += matchedCoreCount * 4.0;

    // 타입별 시그니처 조합 보정.
    fitScore += _getSignatureBonus(profile.id, traitScores);

    // 반대 성향이면 감점.
    fitScore += _getConflictPenalty(profile.id, traitScores);

    return fitScore.clamp(-40, 75);
  }

  double _getSignatureBonus(
    String profileId,
    Map<CattiTrait, int> traitScores,
  ) {
    int v(CattiTrait trait) => traitScores[trait] ?? 0;

    final approach = v(CattiTrait.approach);
    final follow = v(CattiTrait.follow);
    final touch = v(CattiTrait.touch);
    final lap = v(CattiTrait.lap);
    final kneading = v(CattiTrait.kneading);
    final purring = v(CattiTrait.purring);
    final attention = v(CattiTrait.attention);
    final talkative = v(CattiTrait.talkative);
    final curious = v(CattiTrait.curious);
    final explorer = v(CattiTrait.explorer);
    final energy = v(CattiTrait.energy);
    final play = v(CattiTrait.play);
    final hunter = v(CattiTrait.hunter);
    final calm = v(CattiTrait.calm);
    final rest = v(CattiTrait.rest);
    final routine = v(CattiTrait.routine);
    final sun = v(CattiTrait.sun);
    final stable = v(CattiTrait.stable);
    final comfort = v(CattiTrait.comfort);
    final personalSpace = v(CattiTrait.personalSpace);
    final trust = v(CattiTrait.trust);
    final independent = v(CattiTrait.independent);
    final observe = v(CattiTrait.observe);
    final hide = v(CattiTrait.hide);
    final highPlace = v(CattiTrait.highPlace);
    final sleep = v(CattiTrait.sleep);

    switch (profileId) {
      case 'cherry_blossom':
        if (approach >= 10 && curious >= 6 && explorer >= 6) return 22;
        if (approach >= 12 && follow >= 8 && curious >= 5) return 14;
        return 0;

      case 'ribbon':
        if (attention >= 8 && talkative >= 4 && follow >= 8) return 24;
        if (attention >= 8 && touch >= 6 && talkative >= 3) return 16;
        return 0;

      case 'kneading':
        if (touch >= 7 && lap >= 6 && kneading >= 5) return 32;
        if (touch >= 7 && purring >= 4) return 20;
        if (lap >= 6 && purring >= 4) return 14;
        return 0;

      case 'zoomies':
        if (energy >= 10 && play >= 8) return 24;
        if (energy + play + hunter >= 25) return 14;
        return 0;

      case 'feather':
        if (play >= 10 && hunter >= 8) return 28;
        if (play >= 8 && energy >= 8) return 16;
        return 0;

      case 'bread':
        if (calm >= 8 && rest >= 8) return 24;
        if (calm >= 7 && routine >= 5) return 12;
        return 0;

      case 'cactus':
        if (personalSpace >= 10 && independent >= 8) return 28;
        if (personalSpace >= 12 && touch <= 5) return 16;
        return 0;

      case 'queen':
        if (personalSpace >= 10 && trust >= 8 && observe >= 6) return 26;
        if (trust >= 8 && observe >= 8) return 14;
        return 0;

      case 'moon':
        if (observe >= 8 && comfort >= 8 && trust >= 6) return 22;
        if (comfort >= 10 && follow >= 8) return 12;
        return 0;

      case 'box':
        if (hide >= 6 && curious >= 8 && explorer >= 8) return 24;
        if (curious >= 10 && explorer >= 8) return 14;
        return 0;

      case 'explorer':
        if (explorer >= 10 && highPlace >= 8 && curious >= 8) return 28;
        if (explorer >= 10 && curious >= 10) return 16;
        return 0;

      case 'lion':
        if (observe >= 8 && highPlace >= 8 && stable >= 5) return 26;
        if (observe >= 10 && highPlace >= 6) return 16;
        return 0;

      case 'cloud':
        if (comfort >= 10 && rest >= 8 && calm >= 8) return 28;
        if (comfort >= 12 && rest >= 7) return 16;
        return 0;

      case 'nap':
        if (sleep >= 8 && rest >= 8) return 30;
        if (sleep >= 7 && sun >= 5) return 16;
        return 0;

      case 'shy':
        if (hide >= 16 && comfort >= 10 && touch <= 5) return 24;
        if (hide >= 14 && trust >= 6 && touch <= 5) return 14;
        return 0;

      case 'plant':
        if (routine >= 8 && stable >= 8 && comfort >= 8) return 30;
        if (routine >= 7 && rest >= 6) return 16;
        return 0;
    }

    return 0;
  }

  double _getConflictPenalty(
    String profileId,
    Map<CattiTrait, int> traitScores,
  ) {
    int v(CattiTrait trait) => traitScores[trait] ?? 0;

    final approach = v(CattiTrait.approach);
    final follow = v(CattiTrait.follow);
    final touch = v(CattiTrait.touch);
    final lap = v(CattiTrait.lap);
    final kneading = v(CattiTrait.kneading);
    final purring = v(CattiTrait.purring);
    final attention = v(CattiTrait.attention);
    final curious = v(CattiTrait.curious);
    final explorer = v(CattiTrait.explorer);
    final energy = v(CattiTrait.energy);
    final play = v(CattiTrait.play);
    final hunter = v(CattiTrait.hunter);
    final rest = v(CattiTrait.rest);
    final sleep = v(CattiTrait.sleep);
    final personalSpace = v(CattiTrait.personalSpace);
    final hide = v(CattiTrait.hide);

    switch (profileId) {
      case 'cherry_blossom':
        var penalty = 0.0;
        if (hide >= 14 || personalSpace >= 12) penalty -= 16;
        if (attention >= 10 && curious < 6) penalty -= 10;
        if (touch >= 10 && lap >= 8 && curious < 6) penalty -= 12;
        return penalty;

      case 'ribbon':
        var penalty = 0.0;
        if (curious >= 12 && explorer >= 10) penalty -= 14;
        if (hide >= 16 || personalSpace >= 14) penalty -= 16;
        if (kneading >= 8 && lap >= 8) penalty -= 10;
        return penalty;

      case 'kneading':
        var penalty = 0.0;
        if (hide >= 14 && touch <= 5) penalty -= 24;
        if (energy >= 12 || play >= 12 || hunter >= 10) penalty -= 12;
        if (attention >= 10 && lap < 5) penalty -= 10;
        return penalty;

      case 'shy':
        var penalty = 0.0;
        if (touch >= 7 || lap >= 7 || kneading >= 5 || purring >= 5) {
          penalty -= 34;
        }
        if (attention >= 8 && follow >= 8) penalty -= 18;
        if (hide < 12) penalty -= 16;
        return penalty;

      case 'cloud':
      case 'nap':
      case 'bread':
      case 'plant':
        if (energy >= 10 || play >= 10 || hunter >= 10) return -18;
        return 0;

      case 'cactus':
      case 'queen':
        if (touch >= 8 && lap >= 7) return -20;
        if (approach >= 14 && follow >= 10) return -12;
        return 0;

      case 'zoomies':
      case 'feather':
        if (rest >= 10 || sleep >= 8) return -18;
        return 0;

      case 'box':
      case 'explorer':
        if (touch >= 10 || lap >= 8) return -12;
        return 0;

      case 'lion':
      case 'moon':
        if (energy >= 12 || play >= 10) return -12;
        return 0;
    }

    return 0;
  }

  double _getTieBreakerBonus({
    required CattiTypeProfile profile,
    required String? tieBreakerType,
  }) {
    if (tieBreakerType == null || tieBreakerType == 'unknown') return 0;

    final matches = switch (tieBreakerType) {
      'relax' => ['bread', 'cloud', 'nap', 'plant'],
      'play' => ['zoomies', 'feather', 'ribbon'],
      'together' => ['cherry_blossom', 'kneading', 'ribbon', 'shy', 'plant'],
      'explore' => ['box', 'explorer', 'lion'],
      _ => <String>[],
    };

    return matches.contains(profile.id) ? 4 : 0;
  }

  void _addPossibleMaxScores({
    required CattiQuestion question,
    required void Function(double value) onSocial,
    required void Function(double value) onCuriosity,
    required void Function(double value) onActivity,
    required void Function(double value) onEmotion,
  }) {
    double maxSocial = 0;
    double maxCuriosity = 0;
    double maxActivity = 0;
    double maxEmotion = 0;

    for (final option in question.options) {
      for (final score in option.scores) {
        final weightedAbsValue = score.value.abs() * question.weight;

        switch (score.axis) {
          case CattiAxis.social:
            if (weightedAbsValue > maxSocial) maxSocial = weightedAbsValue;
            break;
          case CattiAxis.curiosity:
            if (weightedAbsValue > maxCuriosity) {
              maxCuriosity = weightedAbsValue;
            }
            break;
          case CattiAxis.activity:
            if (weightedAbsValue > maxActivity) {
              maxActivity = weightedAbsValue;
            }
            break;
          case CattiAxis.emotion:
            if (weightedAbsValue > maxEmotion) maxEmotion = weightedAbsValue;
            break;
        }
      }
    }

    onSocial(maxSocial);
    onCuriosity(maxCuriosity);
    onActivity(maxActivity);
    onEmotion(maxEmotion);
  }

  int _rawToPercent(double raw, double maxAbsScore) {
    if (maxAbsScore <= 0) return 50;

    final normalized = ((raw + maxAbsScore) / (maxAbsScore * 2)) * 100;
    return normalized.round().clamp(0, 100);
  }

  double _distance(
    int social,
    int curiosity,
    int activity,
    int emotion,
    int targetSocial,
    int targetCuriosity,
    int targetActivity,
    int targetEmotion,
  ) {
    return sqrt(
      pow(social - targetSocial, 2) +
          pow(curiosity - targetCuriosity, 2) +
          pow(activity - targetActivity, 2) +
          pow(emotion - targetEmotion, 2),
    );
  }

  String? _getTieBreakerType(Map<String, CattiOption> answers) {
    return answers['Q21']?.tieBreakerType;
  }
}

class TopMatchResult {
  final List<CattiMatch> matches;
  final List<Map<String, dynamic>> debug;

  const TopMatchResult({required this.matches, required this.debug});
}

class _ProfileCandidate {
  final CattiTypeProfile profile;
  final double distance;
  final double baseScore;
  final double traitScore;
  final double tieBreakerScore;
  final double finalScore;

  const _ProfileCandidate({
    required this.profile,
    required this.distance,
    required this.baseScore,
    required this.traitScore,
    required this.tieBreakerScore,
    required this.finalScore,
  });

  _ProfileCandidate copyWith({
    double? baseScore,
    double? traitScore,
    double? tieBreakerScore,
    double? finalScore,
  }) {
    return _ProfileCandidate(
      profile: profile,
      distance: distance,
      baseScore: baseScore ?? this.baseScore,
      traitScore: traitScore ?? this.traitScore,
      tieBreakerScore: tieBreakerScore ?? this.tieBreakerScore,
      finalScore: finalScore ?? this.finalScore,
    );
  }
}
