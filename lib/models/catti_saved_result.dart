import 'package:cloud_firestore/cloud_firestore.dart';

class CattiSavedResult {
  final String typeId;
  final String typeName;
  final String emoji;
  final String keyword;
  final String title;
  final int social;
  final int curiosity;
  final int activity;
  final int emotion;
  final DateTime? testedAt;
  final int version;

  CattiSavedResult({
    required this.typeId,
    required this.typeName,
    required this.emoji,
    required this.keyword,
    required this.title,
    required this.social,
    required this.curiosity,
    required this.activity,
    required this.emotion,
    required this.testedAt,
    required this.version,
  });

  factory CattiSavedResult.fromMap(Map<String, dynamic> map) {
    return CattiSavedResult(
      typeId: map['typeId'] ?? '',
      typeName: map['typeName'] ?? '',
      emoji: map['emoji'] ?? '',
      keyword: map['keyword'] ?? '',
      title: map['title'] ?? '',
      social: map['social'] ?? 0,
      curiosity: map['curiosity'] ?? 0,
      activity: map['activity'] ?? 0,
      emotion: map['emotion'] ?? 0,
      testedAt: map['testedAt'] is Timestamp
          ? (map['testedAt'] as Timestamp).toDate()
          : null,
      version: map['version'] ?? 1,
    );
  }
}
