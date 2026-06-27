import 'package:flutter/material.dart';

import '../../models/catti_saved_result.dart';

class CattiProfileCard extends StatelessWidget {
  final CattiSavedResult catti;
  final VoidCallback onTapResult;
  final VoidCallback onTapRetest;

  const CattiProfileCard({
    super.key,
    required this.catti,
    required this.onTapResult,
    required this.onTapRetest,
  });

  String _testedAtText() {
    final testedAt = catti.testedAt;
    if (testedAt == null) return '검사일 정보 없음';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final testedDay = DateTime(testedAt.year, testedAt.month, testedAt.day);
    final diff = today.difference(testedDay).inDays;

    if (diff <= 0) return '오늘 검사';
    if (diff == 1) return '어제 검사';
    if (diff < 7) return '$diff일 전 검사';
    if (diff < 30) return '${(diff / 7).floor()}주 전 검사';
    if (diff < 365) return '${(diff / 30).floor()}개월 전 검사';

    return '${testedAt.year}.${testedAt.month.toString().padLeft(2, '0')}.${testedAt.day.toString().padLeft(2, '0')} 검사';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D5CA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'CATTI',
                style: TextStyle(
                  color: Color(0xFF3D241E),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                _testedAtText(),
                style: const TextStyle(
                  color: Color(0xFFB08A78),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(catti.emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catti.typeName,
                      style: const TextStyle(
                        color: Color(0xFF3D241E),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      catti.keyword,
                      style: const TextStyle(
                        color: Color(0xFF8A5A44),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTapResult,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3D241E),
                    side: const BorderSide(color: Color(0xFFF0D5CA)),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '결과 보기',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTapRetest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD9C9),
                    foregroundColor: const Color(0xFF3D241E),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '다시 검사',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
