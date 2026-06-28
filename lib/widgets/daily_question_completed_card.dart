import 'package:flutter/material.dart';

class DailyQuestionCompletedCard extends StatelessWidget {
  const DailyQuestionCompletedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D5CA)),
      ),
      child: const Row(
        children: [
          Text('🐾', style: TextStyle(fontSize: 22)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 냥문답 완료!',
                  style: TextStyle(
                    color: Color(0xFF3D241E),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '내일 새로운 질문이 찾아올게요.',
                  style: TextStyle(
                    color: Color(0xFF8A6A5A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
