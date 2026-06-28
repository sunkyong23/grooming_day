class DailyQuestion {
  final String id;
  final int month;
  final int day;
  final String question;
  final String hint;
  final String category;
  final String season;
  final String emoji;
  final String cardColor;
  final bool isActive;

  const DailyQuestion({
    required this.id,
    required this.month,
    required this.day,
    required this.question,
    required this.hint,
    required this.category,
    required this.season,
    required this.emoji,
    required this.cardColor,
    required this.isActive,
  });

  factory DailyQuestion.fromJson(Map<String, dynamic> json) {
    return DailyQuestion(
      id: json['id'] as String,
      month: json['month'] as int,
      day: json['day'] as int,
      question: json['question'] as String,
      hint: json['hint'] as String? ?? '',
      category: json['category'] as String? ?? '일상',
      season: json['season'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🐾',
      cardColor: json['cardColor'] as String? ?? '#FFF1EA',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
