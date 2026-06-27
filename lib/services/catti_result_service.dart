import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/catti_type_profiles.dart';
import '../models/catti_result.dart';

class CattiResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCattiResult({
    required String catProfileId,
    required CattiResult result,
  }) async {
    final typeProfile = cattiTypeProfiles.firstWhere(
      (profile) => profile.id == result.code,
    );

    final catRef = _firestore.collection('catProfiles').doc(catProfileId);

    await catRef.update({
      'catti': {
        'typeId': typeProfile.id,
        'typeName': typeProfile.name,
        'emoji': typeProfile.emoji,
        'keyword': typeProfile.keyword,
        'title': typeProfile.title,
        'social': result.socialPercent,
        'curiosity': result.curiosityPercent,
        'activity': result.activityPercent,
        'emotion': result.emotionPercent,
        'testedAt': FieldValue.serverTimestamp(),
        'version': 1,
      },
      'cattiUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
