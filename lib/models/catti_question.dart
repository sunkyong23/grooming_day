enum CattiAxis { social, curiosity, activity, emotion }

enum CattiTrait {
  touch,
  lap,
  kneading,
  purring,
  follow,
  talkative,
  attention,
  approach,
  trust,
  independent,
  personalSpace,
  routine,
  stable,
  curious,
  explorer,
  hide,
  highPlace,
  play,
  hunter,
  energy,
  sleep,
  sun,
  comfort,
  observe,
  calm,
  rest,
}

class CattiScore {
  final CattiAxis axis;
  final int value;

  const CattiScore({required this.axis, required this.value});
}

class CattiTraitScore {
  final CattiTrait trait;
  final int value;

  const CattiTraitScore({required this.trait, required this.value});
}

class CattiQuestion {
  final String id;
  final int number;
  final String category;
  final String icon;
  final String text;
  final double weight;
  final List<CattiOption> options;

  const CattiQuestion({
    required this.id,
    required this.number,
    required this.category,
    required this.icon,
    required this.text,
    this.weight = 1.0,
    required this.options,
  });
}

class CattiOption {
  final String id;
  final String text;
  final List<CattiScore> scores;
  final List<CattiTraitScore> traits;
  final String? tieBreakerType;

  const CattiOption({
    required this.id,
    required this.text,
    required this.scores,
    this.traits = const [],
    this.tieBreakerType,
  });
}
