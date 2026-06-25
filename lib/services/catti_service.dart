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
    final allCandidates = cattiTypeProfiles.map((profile) {
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

      return _ProfileCandidate(
        profile: profile,
        distance: distance,
        baseScore: _distanceToBaseScore(distance),
        traitScore: 0,
        tieBreakerScore: 0,
        finalScore: 0,
      );
    }).toList();

    allCandidates.sort((a, b) => a.distance.compareTo(b.distance));

    final top5 = allCandidates.take(5).map((candidate) {
      final traitScore = _calculateTraitScore(
        profile: candidate.profile,
        traitScores: traitScores,
      );

      final tieBreakerScore = _getTieBreakerBonus(
        profile: candidate.profile,
        tieBreakerType: tieBreakerType,
      );

      final finalScore = candidate.baseScore + traitScore + tieBreakerScore;

      return candidate.copyWith(
        traitScore: traitScore,
        tieBreakerScore: tieBreakerScore,
        finalScore: finalScore,
      );
    }).toList();

    top5.sort((a, b) => b.finalScore.compareTo(a.finalScore));

    final matches = top5.take(3).map((candidate) {
      return CattiMatch(
        typeId: candidate.profile.id,
        matchPercent: candidate.finalScore.round().clamp(0, 100),
      );
    }).toList();

    final debug = top5.map((candidate) {
      return {
        'typeId': candidate.profile.id,
        'distance': candidate.distance.toStringAsFixed(1),
        'baseScore': candidate.baseScore.toStringAsFixed(1),
        'traitScore': candidate.traitScore.toStringAsFixed(1),
        'tieBreakerScore': candidate.tieBreakerScore.toStringAsFixed(1),
        'finalScore': candidate.finalScore.toStringAsFixed(1),
      };
    }).toList();

    return TopMatchResult(matches: matches, debug: debug);
  }

  double _distanceToBaseScore(double distance) {
    const maxDistance = 140.0;
    final normalized = 1 - (distance / maxDistance);
    return (normalized * 68).clamp(0, 68);
  }

  double _calculateTraitScore({
    required CattiTypeProfile profile,
    required Map<CattiTrait, int> traitScores,
  }) {
    double coreMatched = 0;
    double bonusMatched = 0;

    for (final trait in profile.coreTraits) {
      coreMatched += traitScores[trait] ?? 0;
    }

    for (final trait in profile.bonusTraits) {
      bonusMatched += traitScores[trait] ?? 0;
    }

    final coreAverage = profile.coreTraits.isEmpty
        ? 0
        : coreMatched / profile.coreTraits.length;

    final bonusAverage = profile.bonusTraits.isEmpty
        ? 0
        : bonusMatched / profile.bonusTraits.length;

    // Core Trait를 더 강하게 반영하고,
    // Bonus Trait는 세부 보정으로만 사용.
    final weightedAverage = (coreAverage * 0.75) + (bonusAverage * 0.25);

    // 현재 질문 구조상 Trait 평균 18점 전후면 매우 강하게 일치한다고 봄.
    final matchRatio = (weightedAverage / 18).clamp(0.0, 1.0);

    // Trait는 최대 32점까지 반영.
    return matchRatio * 32;
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
    double? traitScore,
    double? tieBreakerScore,
    double? finalScore,
  }) {
    return _ProfileCandidate(
      profile: profile,
      distance: distance,
      baseScore: baseScore,
      traitScore: traitScore ?? this.traitScore,
      tieBreakerScore: tieBreakerScore ?? this.tieBreakerScore,
      finalScore: finalScore ?? this.finalScore,
    );
  }
}
