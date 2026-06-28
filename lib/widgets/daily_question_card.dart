import 'package:flutter/material.dart';

import '../models/daily_question.dart';

class DailyQuestionCard extends StatelessWidget {
  final DailyQuestion question;
  final VoidCallback? onTapAnswer;
  final VoidCallback? onTapDismiss;

  const DailyQuestionCard({
    super.key,
    required this.question,
    this.onTapAnswer,
    this.onTapDismiss,
  });

  Color _parseColor(String hexColor) {
    final cleanHex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(question.cardColor);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D5CA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '오늘의 냥문답',
                style: TextStyle(
                  color: Color(0xFF8A5A44),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(question.emoji, style: const TextStyle(fontSize: 15)),
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
          const SizedBox(height: 10),
          Text(
            question.question,
            style: const TextStyle(
              color: Color(0xFF3D241E),
              fontSize: 17,
              fontWeight: FontWeight.w800,
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
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onTapAnswer,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9C9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '답변하러 가기',
                  style: TextStyle(
                    color: Color(0xFF5C4033),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
