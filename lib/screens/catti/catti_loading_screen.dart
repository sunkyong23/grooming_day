import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/catti_question.dart';
import '../../models/catti_result.dart';
import 'catti_reveal_screen.dart';

class CattiLoadingScreen extends StatefulWidget {
  final String catProfileId;
  final String catName;
  final CattiResult result;
  final Map<String, CattiOption> answers;

  const CattiLoadingScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
    required this.result,
    required this.answers,
  });

  @override
  State<CattiLoadingScreen> createState() => _CattiLoadingScreenState();
}

class _CattiLoadingScreenState extends State<CattiLoadingScreen> {
  int progress = 0;
  Timer? timer;
  bool _openedReveal = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 14), (timer) {
      if (!mounted) return;

      if (progress >= 100) {
        timer.cancel();
        _openReveal();
        return;
      }

      setState(() {
        progress++;
      });
    });
  }

  Future<void> _openReveal() async {
    if (_openedReveal) return;
    _openedReveal = true;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CattiRevealScreen(
          catProfileId: widget.catProfileId,
          catName: widget.catName,
          result: widget.result,
          answers: widget.answers,
        ),
      ),
    );

    if (saved == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐾', style: TextStyle(fontSize: 58)),
                const SizedBox(height: 22),
                const Text(
                  '우리 냥이만의\n특별한 성향을 분석하는 중...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D241E),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE8A58C),
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFF3DDD3),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFE8A58C)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
