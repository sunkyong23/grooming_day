import 'package:flutter/material.dart';

import '../../data/catti_type_profiles.dart';
import '../../models/catti_question.dart';
import '../../models/catti_result.dart';
import '../../widgets/catti/catti_radar_chart.dart';
import '../../services/catti_result_service.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class CattiResultScreen extends StatefulWidget {
  final String catProfileId;
  final String catName;
  final CattiResult result;
  final Map<String, CattiOption> answers;

  final bool readOnly;
  final bool canShare;

  const CattiResultScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
    required this.result,
    required this.answers,
    this.readOnly = false,
    this.canShare = true,
  });

  @override
  State<CattiResultScreen> createState() => _CattiResultScreenState();
}

class _CattiResultScreenState extends State<CattiResultScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _shareKey = GlobalKey();
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

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pop(context, true);
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

  Future<void> _shareResult() async {
    if (!widget.canShare) return;

    try {
      await Future.delayed(const Duration(milliseconds: 120));

      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('공유 영역을 찾을 수 없어요.');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('이미지 변환에 실패했어요.');
      }

      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/catti_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: '${widget.catName}의 CATTI 결과 🐾',
        ),
      );
    } catch (e, stack) {
      debugPrint('CATTI SHARE ERROR: $e');
      debugPrint('$stack');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('공유 이미지 오류: $e')));
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

  @override
  Widget build(BuildContext context) {
    final profile = cattiTypeProfiles.firstWhere(
      (profile) => profile.id == widget.result.code,
    );

    final similarProfiles = _similarProfiles(profile);

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
                  RepaintBoundary(
                    key: _shareKey,
                    child: Container(
                      color: const Color(0xFFFFF8F4),
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        children: [
                          _shareHeader(profile),
                          const SizedBox(height: 22),
                          _sectionCard(
                            child: Column(
                              children: [
                                CattiRadarChart(
                                  key: ValueKey(
                                    '${widget.result.code}-${widget.result.socialPercent}-${widget.result.curiosityPercent}-${widget.result.activityPercent}-${widget.result.emotionPercent}',
                                  ),
                                  socialPercent: widget.result.socialPercent,
                                  curiosityPercent:
                                      widget.result.curiosityPercent,
                                  activityPercent:
                                      widget.result.activityPercent,
                                  emotionPercent: widget.result.emotionPercent,
                                ),
                                const SizedBox(height: 12),
                                _scoreRow('사교성', widget.result.socialPercent),
                                _scoreRow(
                                  '호기심',
                                  widget.result.curiosityPercent,
                                ),
                                _scoreRow('활동성', widget.result.activityPercent),
                                _scoreRow('감정표현', widget.result.emotionPercent),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _sectionCard(
                            title: '대표 키워드',
                            child: Center(
                              child: Text(
                                '${profile.emoji} ${profile.keyword}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF3D241E),
                                  fontSize: 22,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _sectionCard(
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
                          const SizedBox(height: 16),
                          _sectionCard(
                            title: '비슷한 냥이',
                            child: Column(
                              children: similarProfiles
                                  .map(
                                    (item) => _similarTypeRow(
                                      item.profile,
                                      item.percent,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _sectionCard(
                            title: '이런 모습을 보여요',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: profile.traits
                                  .take(3)
                                  .map((text) => _compactBullet(text))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _sectionCard(
                            title: '집사가 알아두면 좋아요',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: profile.tips
                                  .take(2)
                                  .map((text) => _compactBullet(text))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _smallNoteCard(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _actionButtons(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _shareHeader(dynamic profile) {
    return FadeTransition(
      opacity: _headerOpacity,
      child: SlideTransition(
        position: _headerSlide,
        child: ScaleTransition(
          scale: _headerScale,
          child: Column(
            children: [
              Text(profile.emoji, style: const TextStyle(fontSize: 58)),
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
                  fontWeight: FontWeight.w700,
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
    );
  }

  Widget _actionButtons() {
    if (widget.readOnly) {
      if (!widget.canShare) {
        return const SizedBox.shrink();
      }

      return FadeTransition(
        opacity: _buttonOpacity,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _shareResult,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3D241E),
              side: const BorderSide(color: Color(0xFFF0D5CA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  '공유하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _buttonOpacity,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: _shareResult,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3D241E),
                  side: const BorderSide(color: Color(0xFFF0D5CA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '공유하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving || _saved ? null : _saveResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD9C9),
                  foregroundColor: const Color(0xFF3D241E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
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
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
          ],
          child,
        ],
      ),
    );
  }

  Widget _compactBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        '• $text',
        style: const TextStyle(
          color: Color(0xFF6B4A3A),
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<({dynamic profile, int percent})> _similarProfiles(
    dynamic currentProfile,
  ) {
    final maxDistance = 400;

    final sorted =
        cattiTypeProfiles.where((item) => item.id != currentProfile.id).map((
          item,
        ) {
          final distance = _profileDistance(currentProfile, item);
          final percent = ((1 - (distance / maxDistance)) * 100)
              .clamp(0, 100)
              .round();

          return (profile: item, percent: percent);
        }).toList()..sort((a, b) => b.percent.compareTo(a.percent));

    return sorted.take(2).toList();
  }

  int _profileDistance(dynamic a, dynamic b) {
    return (a.targetSocial - b.targetSocial).abs() +
        (a.targetCuriosity - b.targetCuriosity).abs() +
        (a.targetActivity - b.targetActivity).abs() +
        (a.targetEmotion - b.targetEmotion).abs();
  }

  Widget _similarTypeRow(dynamic profile, int percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(profile.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Color(0xFF3D241E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.keyword,
                  style: const TextStyle(
                    color: Color(0xFF9A7A6A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EA),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF0D5CA)),
            ),
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: Color(0xFFE09086),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATTI는 정답을 맞히는 검사가 아닙니다.\n\n'
          '우리 냥이를 조금 더 오래 바라보고\n'
          '조금 더 이해하기 위한 작은 관찰 기록이에요.\n\n'
          '모든 고양이는 저마다의 방식으로 우리를 사랑하고 있어요.',
          style: TextStyle(
            color: Color(0xFF9A7A6A),
            fontSize: 12,
            height: 1.75,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFE6D8D2),
        ),
        const SizedBox(height: 12),
        const Text(
          'GroomingDay CATTI\ngroomingday.app',
          style: TextStyle(
            color: Color(0xFFC7B2A9),
            fontSize: 11,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
