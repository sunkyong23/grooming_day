import 'package:flutter/material.dart';

import '../../data/catti_type_profiles.dart';
import '../../models/catti_question.dart';
import '../../models/catti_result.dart';
import '../../widgets/catti/catti_radar_chart.dart';
import '../../services/catti_result_service.dart';

class CattiResultScreen extends StatefulWidget {
  final String catProfileId;
  final String catName;
  final CattiResult result;
  final Map<String, CattiOption> answers;

  final bool readOnly;

  const CattiResultScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
    required this.result,
    required this.answers,
    this.readOnly = false,
  });

  @override
  State<CattiResultScreen> createState() => _CattiResultScreenState();
}

class _CattiResultScreenState extends State<CattiResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _headerOpacity;
  late final Animation<double> _headerScale;
  late final Animation<Offset> _headerSlide;

  late final Animation<double> _buttonOpacity;

  final CattiResultService _cattiResultService = CattiResultService();
  bool _isSaving = false;
  bool _saved = false;

  Future<void> _saveResult() async {
    if (_isSaving || _saved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _cattiResultService.saveCattiResult(
        catProfileId: widget.catProfileId,
        result: widget.result,
      );

      if (!mounted) return;

      setState(() {
        _saved = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CATTI 결과를 프로필에 저장했어요.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 문제가 발생했어요. 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _headerOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.28, curve: Curves.easeOut),
    );

    _headerScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.32, curve: Curves.easeOutBack),
      ),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.00, 0.32, curve: Curves.easeOutCubic),
          ),
        );

    _buttonOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.86, 1.00, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _fade(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slide(double begin, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _appear({
    required double begin,
    required double end,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: _fade(begin, end),
      child: SlideTransition(position: _slide(begin, end), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = cattiTypeProfiles.firstWhere(
      (profile) => profile.id == widget.result.code,
    );

    final similarMatches = widget.result.topMatches
        .where((match) => match.typeId != widget.result.code)
        .take(2)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        title: Text(widget.readOnly ? 'CATTI 기록' : 'CATTI 결과'),
        backgroundColor: const Color(0xFFFFF8F4),
        elevation: 0,
        foregroundColor: const Color(0xFF3D241E),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                children: [
                  FadeTransition(
                    opacity: _headerOpacity,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: ScaleTransition(
                        scale: _headerScale,
                        child: Column(
                          children: [
                            Text(
                              profile.emoji,
                              style: const TextStyle(fontSize: 58),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${widget.catName}의 CATTI',
                              style: const TextStyle(
                                color: Color(0xFFB48A78),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile.name,
                              style: const TextStyle(
                                color: Color(0xFF3D241E),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF6B4A3A),
                                fontSize: 17,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _sectionCard(
                    child: Column(
                      children: [
                        CattiRadarChart(
                          key: ValueKey(
                            '${widget.result.code}-${widget.result.socialPercent}-${widget.result.curiosityPercent}-${widget.result.activityPercent}-${widget.result.emotionPercent}',
                          ),
                          socialPercent: widget.result.socialPercent,
                          curiosityPercent: widget.result.curiosityPercent,
                          activityPercent: widget.result.activityPercent,
                          emotionPercent: widget.result.emotionPercent,
                        ),
                        const SizedBox(height: 12),
                        _scoreRow('사교성', widget.result.socialPercent),
                        _scoreRow('호기심', widget.result.curiosityPercent),
                        _scoreRow('활동성', widget.result.activityPercent),
                        _scoreRow('감정표현', widget.result.emotionPercent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _appear(
                    begin: 0.22,
                    end: 0.40,
                    child: _sectionCard(
                      title: '대표 키워드',
                      child: Center(
                        child: Text(
                          '${profile.emoji} ${profile.keyword}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF3D241E),
                            fontSize: 22,
                            height: 1.35,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (similarMatches.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _appear(
                      begin: 0.34,
                      end: 0.52,
                      child: _sectionCard(
                        title: '비슷한 모습도 있어요',
                        child: Column(
                          children: similarMatches.map((match) {
                            final matchProfile = cattiTypeProfiles.firstWhere(
                              (profile) => profile.id == match.typeId,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    matchProfile.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      matchProfile.name,
                                      style: const TextStyle(
                                        color: Color(0xFF3D241E),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  TweenAnimationBuilder<int>(
                                    tween: IntTween(
                                      begin: 0,
                                      end: match.matchPercent,
                                    ),
                                    duration: const Duration(
                                      milliseconds: 1400,
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, _) {
                                      return Text(
                                        '$value%',
                                        style: const TextStyle(
                                          color: Color(0xFFE8A58C),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  _appear(
                    begin: 0.46,
                    end: 0.64,
                    child: _sectionCard(
                      child: Text(
                        profile.description,
                        style: const TextStyle(
                          color: Color(0xFF6B4A3A),
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _appear(
                    begin: 0.58,
                    end: 0.76,
                    child: _sectionCard(
                      title: '이런 모습을 보여요',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: profile.traits
                            .map((text) => _bullet(text))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _appear(
                    begin: 0.68,
                    end: 0.86,
                    child: _sectionCard(
                      title: '집사가 알아두면 좋아요',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: profile.tips
                            .map((text) => _bullet(text))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _appear(begin: 0.78, end: 0.96, child: _smallNoteCard()),

                  if (!widget.readOnly &&
                      widget.result.debugInfo.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _appear(begin: 0.76, end: 0.96, child: _debugCard()),
                  ],

                  if (!widget.readOnly) ...[
                    const SizedBox(height: 22),
                    FadeTransition(
                      opacity: _buttonOpacity,
                      child: SizedBox(
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
                          onPressed: _isSaving || _saved ? null : _saveResult,
                          child: Text(
                            _isSaving
                                ? '저장 중...'
                                : _saved
                                ? '저장 완료'
                                : '프로필에 저장하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D5CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF3D241E),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 22),
          ],
          child,
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        '• $text',
        style: const TextStyle(
          color: Color(0xFF6B4A3A),
          fontSize: 14.5,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _scoreRow(String label, int percent) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percent.toDouble()),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final animatedPercent = value.round();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B4A3A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF4DDD3),
                    color: const Color(0xFFE8A58C),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 48,
                child: Text(
                  '$animatedPercent%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF3D241E),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _debugCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🐞 DEBUG',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),
            Text('Social : ${widget.result.socialPercent}'),
            Text('Curiosity : ${widget.result.curiosityPercent}'),
            Text('Activity : ${widget.result.activityPercent}'),
            Text('Emotion : ${widget.result.emotionPercent}'),
            const SizedBox(height: 16),
            const Text(
              'Top Matches',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...widget.result.topMatches.map(
              (e) => Text('${e.typeId}   ${e.matchPercent}%'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trait Scores',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...widget.result.debugInfo.entries.map(
              (e) => Text('${e.key} : ${e.value}'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _smallNoteCard() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 6),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8F4),
      borderRadius: BorderRadius.circular(18),
    ),
    child: RichText(
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFF9A7A6A),
          fontSize: 12,
          height: 1.75,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text:
                'CATTI는 정답을 맞히는 검사가 아닙니다.\n\n'
                '우리 냥이를 조금 더 오래 바라보고,\n'
                '조금 더 이해하기 위한 작은 관찰 기록이에요.\n\n',
          ),
          TextSpan(
            text: '모든 고양이는 저마다의 방식으로\n우리를 사랑하고 있어요.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}
