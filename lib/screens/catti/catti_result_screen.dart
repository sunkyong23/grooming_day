import 'package:flutter/material.dart';

import '../../data/catti_type_profiles.dart';
import '../../models/catti_question.dart';
import '../../models/catti_result.dart';
import '../../widgets/catti/catti_radar_chart.dart';

class CattiResultScreen extends StatelessWidget {
  final String catProfileId;
  final String catName;
  final CattiResult result;
  final Map<String, CattiOption> answers;

  const CattiResultScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
    required this.result,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final profile = cattiTypeProfiles.firstWhere(
      (profile) => profile.id == result.code,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        title: const Text('CATTI 결과'),
        backgroundColor: const Color(0xFFFFF8F4),
        elevation: 0,
        foregroundColor: const Color(0xFF3D241E),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            children: [
              Text(profile.emoji, style: const TextStyle(fontSize: 58)),
              const SizedBox(height: 12),
              Text(
                '$catName의 CATTI',
                style: const TextStyle(
                  color: Color(0xFFB48A78),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.name,
                style: const TextStyle(
                  color: Color(0xFF3D241E),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B4A3A),
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              _sectionCard(
                title: '우리 냥이를 한눈에 보면',
                child: Column(
                  children: [
                    CattiRadarChart(
                      socialPercent: result.socialPercent,
                      curiosityPercent: result.curiosityPercent,
                      activityPercent: result.activityPercent,
                      emotionPercent: result.emotionPercent,
                    ),
                    const SizedBox(height: 12),
                    _scoreRow('사교성', result.socialPercent),
                    _scoreRow('호기심', result.curiosityPercent),
                    _scoreRow('활동성', result.activityPercent),
                    _scoreRow('감정표현', result.emotionPercent),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: '대표 키워드',
                child: Center(
                  child: Text(
                    '${profile.emoji} ${profile.keyword}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF3D241E),
                      fontSize: 22,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: '비슷한 모습도 있어요',
                child: Column(
                  children: result.topMatches
                      .where((match) => match.typeId != result.code)
                      .take(2)
                      .map((match) {
                        final matchProfile = cattiTypeProfiles.firstWhere(
                          (profile) => profile.id == match.typeId,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                matchProfile.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  matchProfile.name,
                                  style: const TextStyle(
                                    color: Color(0xFF3D241E),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '${match.matchPercent}%',
                                style: const TextStyle(
                                  color: Color(0xFFE8A58C),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: '이야기',
                child: Text(
                  profile.description,
                  style: const TextStyle(
                    color: Color(0xFF6B4A3A),
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: '이런 모습을 보여요',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: profile.traits
                      .map((text) => _bullet(text))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: '집사가 알아두면 좋아요',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: profile.tips.map((text) => _bullet(text)).toList(),
                ),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: 'CATTI가 전하고 싶은 이야기',
                child: const Text(
                  '모든 고양이는 같은 방식으로 사랑하지 않습니다.\n\n'
                  '하지만 모든 고양이는, 저마다의 방식으로 우리를 사랑합니다.\n\n'
                  'CATTI는 정답을 찾는 검사가 아니라,\n'
                  '우리 냥이를 조금 더 오래 바라보고,\n'
                  '조금 더 깊이 이해하기 위한 작은 관찰 기록입니다.\n\n'
                  '오늘도 함께해 줘서 고마워.\n\n'
                  '- GroomingDay CATTI - 🐾',
                  style: TextStyle(
                    color: Color(0xFF6B4A3A),
                    fontSize: 14.5,
                    height: 1.65,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🐞 DEBUG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text('Social : ${result.socialPercent}'),
                      Text('Curiosity : ${result.curiosityPercent}'),
                      Text('Activity : ${result.activityPercent}'),
                      Text('Emotion : ${result.emotionPercent}'),

                      const SizedBox(height: 16),

                      const Text(
                        'Top Matches',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      ...result.topMatches.map(
                        (e) => Text('${e.typeId}   ${e.matchPercent}%'),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Trait Scores',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      ...result.debugInfo.entries.map(
                        (e) => Text('${e.key} : ${e.value}'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD9C9),
                    foregroundColor: const Color(0xFF3D241E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('다음 단계에서 저장 기능을 연결할게요.')),
                    );
                  },
                  child: const Text(
                    '프로필에 저장하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D5CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF3D241E),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        '• $text',
        style: const TextStyle(
          color: Color(0xFF6B4A3A),
          fontSize: 14.5,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _scoreRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B4A3A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFF3DDD3),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE8A58C)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              '$value%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF3D241E),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
