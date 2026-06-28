import 'package:flutter/material.dart';

import '../models/daily_question.dart';

class DailyQuestionCardV2 extends StatelessWidget {
  final DailyQuestion question;
  final bool answered;
  final int answerCount;
  final VoidCallback? onTapAnswer;
  final VoidCallback? onTapFeed;
  final VoidCallback? onTapDismiss;

  const DailyQuestionCardV2({
    super.key,
    required this.question,
    required this.answered,
    required this.answerCount,
    this.onTapAnswer,
    this.onTapFeed,
    this.onTapDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final countText = answerCount == 0
        ? '아직 올라온 답변이 없어요'
        : '오늘 답변 $answerCount개';

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D5CA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: answered
          ? _answeredContent(countText)
          : _questionContent(countText),
    );
  }

  Widget _questionContent(String countText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(question.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            const Text(
              '오늘의 냥문답',
              style: TextStyle(
                color: Color(0xFF8A5A44),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onTapDismiss,
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFFB89B8D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          question.question,
          style: const TextStyle(
            color: Color(0xFF3D241E),
            fontSize: 17,
            fontWeight: FontWeight.w900,
            height: 1.35,
          ),
        ),
        if (question.hint.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            question.hint,
            style: const TextStyle(
              color: Color(0xFF8A6A5A),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onTapFeed,
          child: Text(
            countText,
            style: const TextStyle(
              color: Color(0xFF8A6A5A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTapAnswer,
                child: Container(
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9C9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '답변하기',
                    style: TextStyle(
                      color: Color(0xFF5C4033),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onTapFeed,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF0D5CA)),
                ),
                child: const Text(
                  '보러가기',
                  style: TextStyle(
                    color: Color(0xFF8A5A44),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _answeredContent(String countText) {
    return GestureDetector(
      onTap: onTapFeed,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘 참여 완료!',
                  style: TextStyle(
                    color: Color(0xFF3D241E),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  countText,
                  style: const TextStyle(
                    color: Color(0xFF8A6A5A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '다른 집사들 보러가기 →',
                  style: TextStyle(
                    color: Color(0xFFE09086),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFB08678),
            size: 24,
          ),
        ],
      ),
    );
  }
}
