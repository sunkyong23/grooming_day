import 'package:flutter/material.dart';

import '../models/daily_question.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyQuestionCardV2 extends StatefulWidget {
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
  State<DailyQuestionCardV2> createState() => _DailyQuestionCardV2State();
}

class _DailyQuestionCardV2State extends State<DailyQuestionCardV2> {
  bool _expanded = true;
  bool _isExpandedStateLoaded = false;

  String _todayKey() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _expandedPrefKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'daily_question_card_expanded_${uid}_${_todayKey()}';
  }

  @override
  void initState() {
    super.initState();
    _loadExpandedState();
  }

  Future<void> _loadExpandedState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_expandedPrefKey());

    if (!mounted) return;

    setState(() {
      _expanded = saved ?? true;
      _isExpandedStateLoaded = true;
    });
  }

  Future<void> _saveExpandedState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_expandedPrefKey(), value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpandedStateLoaded) {
      return const SizedBox.shrink();
    }

    final answeredCountText = widget.answerCount == 0
        ? '아직 올라온 답변이 없어요'
        : '오늘 답변 ${widget.answerCount}개';

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      padding: _expanded
          ? const EdgeInsets.fromLTRB(18, 14, 18, 14)
          : const EdgeInsets.fromLTRB(18, 10, 18, 10),
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
      child: widget.answered
          ? _answeredContent(answeredCountText)
          : _questionContent(),
    );
  }

  Widget _header() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final nextExpanded = !_expanded;

        setState(() {
          _expanded = nextExpanded;
        });

        await _saveExpandedState(nextExpanded);
      },
      child: Row(
        children: [
          const Icon(Icons.pets_rounded, size: 18, color: Color(0xFF8A5A44)),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              '오늘의 냥문답',
              style: TextStyle(
                color: Color(0xFF8A5A44),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4D6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB58A7B).withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: Color(0xFF8A5A44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                widget.question.question,
                style: const TextStyle(
                  color: Color(0xFF3D241E),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              if (widget.question.hint.isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(
                  widget.question.hint,
                  style: const TextStyle(
                    color: Color(0xFF8A6A5A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: widget.onTapAnswer,
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
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: widget.onTapFeed,
                  child: Text(
                    widget.answerCount == 0
                        ? '오늘의 답변 보러가기 →'
                        : '오늘 답변 ${widget.answerCount}개 보러가기 →',
                    style: const TextStyle(
                      color: Color(0xFFE09086),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onTapDismiss,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      '오늘은 건너뛰기',
                      style: TextStyle(
                        color: Color(0xFFB8A59A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _answeredContent(String countText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 14),
              GestureDetector(
                onTap: widget.onTapFeed,
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
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onTapDismiss,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10, right: 4),
                    child: Text(
                      '오늘은 숨기기',
                      style: TextStyle(
                        color: Color(0xFFB8A59A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
