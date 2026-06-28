import 'package:flutter/material.dart';

class DailyQuestionInfoCard extends StatelessWidget {
  final bool answered;
  final int answerCount;
  final VoidCallback? onTap;

  const DailyQuestionInfoCard({
    super.key,
    required this.answered,
    required this.answerCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = answered ? '🎉 오늘 참여 완료!' : '🐾 오늘의 냥문답';
    final actionText = answered ? '다른 집사들 보러가기 →' : '지금 참여해보세요 →';

    final countText = answerCount == 0
        ? '아직 올라온 답변이 없어요'
        : '오늘 답변 $answerCount개';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 10, 22, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0D5CA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB58A7B).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1EA),
                shape: BoxShape.circle,
              ),
              child: Text(
                answered ? '🎉' : '🐾',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF3D241E),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    countText,
                    style: const TextStyle(
                      color: Color(0xFF8A6A5A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFFE09086),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB08678),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
