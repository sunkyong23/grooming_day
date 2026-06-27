import 'package:flutter/material.dart';

import '../../models/cat_profile.dart';
import '../../screens/catti/catti_intro_screen.dart';
import 'catti_profile_card.dart';

import '../../models/catti_result.dart';
import '../../screens/catti/catti_result_screen.dart';

class CattiCard extends StatelessWidget {
  final CatProfile catProfile;

  const CattiCard({super.key, required this.catProfile});

  void _openCattiTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CattiIntroScreen(
          catProfileId: catProfile.id,
          catName: catProfile.name,
        ),
      ),
    );
  }

  Future<void> _confirmRetest(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '다시 검사할까요?',
            style: TextStyle(
              color: Color(0xFF3D241E),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '${catProfile.name}의 새로운 CATTI 검사를 시작할게요.\n'
            '기존 결과는 새 결과를 저장하기 전까지 유지돼요.',
            style: const TextStyle(
              color: Color(0xFF6B4A3A),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF8A6A5A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD9C9),
                foregroundColor: const Color(0xFF3D241E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '다시 검사',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      _openCattiTest(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedCatti = catProfile.catti;

    if (savedCatti != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CattiProfileCard(
          catti: savedCatti,

          onTapResult: () {
            final result = CattiResult.fromSaved(savedCatti);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CattiResultScreen(
                  catProfileId: catProfile.id,
                  catName: catProfile.name,
                  result: result,
                  answers: const {},
                  readOnly: true,
                ),
              ),
            );
          },

          onTapRetest: () {
            _confirmRetest(context);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          _openCattiTest(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFFF8F5)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0D5CA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE9DE),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🐾', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATTI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3D241E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cat Type Indicator',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB08678),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('✨', style: TextStyle(fontSize: 20)),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                '${catProfile.name}의 성향을\n관찰해보세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D241E),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                '20개의 질문으로 우리 냥이를 더 오래 바라보고\n이해하기 위한 작은 관찰 기록이에요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8C6A5F),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD9C9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'CATTI 검사하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3D241E),
                    ),
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
