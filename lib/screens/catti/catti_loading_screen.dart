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
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      Navigator.pushReplacement(
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8F4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🐾', style: TextStyle(fontSize: 58)),
                SizedBox(height: 22),
                Text(
                  '우리 냥이의 성향을\n살펴보는 중...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D241E),
                  ),
                ),
                SizedBox(height: 22),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFFE8A58C),
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
