import 'package:flutter/material.dart';

import 'catti_test_screen.dart';

class CattiIntroScreen extends StatelessWidget {
  final String catProfileId;
  final String catName;

  const CattiIntroScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        title: const Text('CATTI'),
        backgroundColor: const Color(0xFFFFF8F4),
        elevation: 0,
        foregroundColor: const Color(0xFF3D241E),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 20),
              Text(
                '$catName의\nCATTI를 알아볼까요?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D241E),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'CATTI는 고양이를 분류하기 위한 검사가 아니라,\n'
                '우리 냥이를 더 오래 바라보고 이해하기 위한\n'
                '작은 관찰 기록이에요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Color(0xFF8A6A5B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF0D5CA)),
                ),
                child: const Text(
                  '정답은 없어요.\n'
                  '가장 평소와 가까운 모습을 선택해주세요.\n\n'
                  '나이, 건강 상태, 환경에 따라\n'
                  '행동은 달라질 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF6B4A3A),
                  ),
                ),
              ),
              const Spacer(),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CattiTestScreen(
                          catProfileId: catProfileId,
                          catName: catName,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '검사 시작하기',
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
}
