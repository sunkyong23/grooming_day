import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/catti_today_messages.dart';
import '../../data/catti_type_profiles.dart';
import '../../models/catti_question.dart';
import '../../models/catti_result.dart';
import 'catti_result_screen.dart';

class CattiRevealScreen extends StatefulWidget {
  final String catProfileId;
  final String catName;
  final CattiResult result;
  final Map<String, CattiOption> answers;

  const CattiRevealScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
    required this.result,
    required this.answers,
  });

  @override
  State<CattiRevealScreen> createState() => _CattiRevealScreenState();
}

class _CattiRevealScreenState extends State<CattiRevealScreen> {
  int step = 0;
  Timer? stepTimer1;
  Timer? stepTimer2;
  Timer? stepTimer3;

  late final String todayMessage;

  @override
  void initState() {
    super.initState();

    todayMessage =
        cattiTodayMessages[Random().nextInt(cattiTodayMessages.length)];

    stepTimer1 = Timer(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => step = 1);
    });

    stepTimer2 = Timer(const Duration(milliseconds: 1650), () {
      if (mounted) setState(() => step = 2);
    });

    stepTimer3 = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => step = 3);
    });
  }

  @override
  void dispose() {
    stepTimer1?.cancel();
    stepTimer2?.cancel();
    stepTimer3?.cancel();

    super.dispose();
  }

  void _goToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CattiResultScreen(
          catProfileId: widget.catProfileId,
          catName: widget.catName,
          result: widget.result,
          answers: widget.answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = cattiTypeProfiles.firstWhere(
      (profile) => profile.id == widget.result.code,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SafeArea(
        child: Stack(
          children: [
            const _SoftBackground(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 620),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.045),
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _buildStep(profile),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(dynamic profile) {
    if (step == 0) {
      return _messageStep(
        key: const ValueKey('step0'),
        icon: '🐾',
        text: '우리 아이를\n살펴보고 있어요.',
      );
    }

    if (step == 1) {
      return _messageStep(
        key: const ValueKey('step1'),
        icon: '✨',
        text: '성향을\n정리하고 있어요.',
      );
    }

    if (step == 2) {
      return _messageStep(
        key: const ValueKey('step2'),
        icon: '🐱',
        text: '가장 닮은 모습을\n찾았어요.',
      );
    }

    return _resultRevealStep(profile);
  }

  Widget _messageStep({
    required Key key,
    required String icon,
    required String text,
  }) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.82, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Text(icon, style: const TextStyle(fontSize: 60)),
        ),
        const SizedBox(height: 22),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF3D241E),
            fontSize: 27,
            height: 1.35,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 26),
        const _DotLoading(),
      ],
    );
  }

  Widget _resultRevealStep(dynamic profile) {
    return Column(
      key: const ValueKey('step3'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'CATTI 분석 완료',
          style: TextStyle(
            color: Color(0xFFB48A78),
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 22),

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.45, end: 1),
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD9C9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8A58C).withValues(alpha: 0.2),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Text(profile.emoji, style: const TextStyle(fontSize: 64)),
          ),
        ),

        const SizedBox(height: 26),

        Text(
          '${profile.name}을 발견했어요',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF3D241E),
            fontSize: 32,
            height: 1.25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          profile.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B4A3A),
            fontSize: 16.5,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 30),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0D5CA)),
          ),
          child: Column(
            children: [
              const Text(
                '🌤 오늘의 한마디',
                style: TextStyle(
                  color: Color(0xFFB48A78),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                todayMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A5A44),
                  fontSize: 16,
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOut,
          builder: (context, opacity, child) {
            return Opacity(opacity: opacity, child: child);
          },
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD9C9),
                foregroundColor: const Color(0xFF3D241E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _goToResult,
              child: const Text(
                '결과 확인하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _BlurCircle(
            size: 190,
            color: const Color(0xFFFFD9C9).withValues(alpha: 0.55),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -70,
          child: _BlurCircle(
            size: 210,
            color: const Color(0xFFE8A58C).withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          top: 120,
          left: 28,
          child: Text(
            '✦',
            style: TextStyle(
              color: const Color(0xFFE8A58C).withValues(alpha: 0.32),
              fontSize: 20,
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          right: 38,
          child: Text(
            '✦',
            style: TextStyle(
              color: const Color(0xFFE8A58C).withValues(alpha: 0.26),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DotLoading extends StatefulWidget {
  const _DotLoading();

  @override
  State<_DotLoading> createState() => _DotLoadingState();
}

class _DotLoadingState extends State<_DotLoading> {
  int activeIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;
      setState(() {
        activeIndex = (activeIndex + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final selected = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 9 : 7,
          height: selected ? 9 : 7,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE8A58C)
                : const Color(0xFFE8A58C).withValues(alpha: 0.28),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
