import 'package:flutter/material.dart';

import '../models/rainbow_letter.dart';
import '../services/rainbow_service.dart';
import 'create_rainbow_letter_screen.dart';
import 'rainbow_letter_detail_screen.dart';

class RainbowScreen extends StatefulWidget {
  const RainbowScreen({super.key});

  @override
  State<RainbowScreen> createState() => _RainbowScreenState();
}

class _RainbowScreenState extends State<RainbowScreen> {
  List<RainbowLetter> letters = [];
  List<RainbowLetter> myLetters = [];
  bool isLoading = true;
  late String selectedMessage;

  final List<String> comfortMessages = [
    '오늘도 무지개별에서 평온한 하루를 보냈어요.',
    '오늘도 친구들과 사이좋게 뛰어놀고 있어요.',
    '오늘도 걱정하지 마세요. 행복하게 지내고 있어요.',
    '오늘도 맛있는 간식을 먹고 기분 좋은 하루를 보내고 있어요.',
    '언제나 마음속에서 함께하고 있어요.',
    '가끔 그리워도 너무 슬퍼하지 말아요.',
    '함께했던 따뜻한 기억을 소중히 간직하고 있어요.',
    '오늘도 사랑받던 기억을 떠올리며 하루를 보냈어요.',
    '늘 곁에 있는 것처럼 기억해 주세요.',
    '우리의 추억은 여전히 따뜻하게 빛나고 있어요.',
    '함께한 시간들은 영원히 사라지지 않아요.',
    '사랑받았던 기억은 언제나 마음속에 남아 있어요.',
    '눈에 보이지 않아도 마음은 늘 함께예요.',
    '아껴주고 사랑해줘서 너무 고마웠어요.',
    '우리는 여전히 같은 하늘 아래 있어요.',
    '소중했던 날들을 잊지 않고 있어요.',
    '오늘은 문득 우리의 추억이 떠올랐던 하루였어요.',
    '언제나 고맙고, 언제나 사랑하고 있어요.',
  ];

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    final index =
        (today.year + today.month + today.day) % comfortMessages.length;

    selectedMessage = comfortMessages[index];

    loadLetters();
  }

  Future<void> loadLetters() async {
    setState(() {
      isLoading = true;
    });

    final publicSnapshot = await RainbowService().loadPublicLetters();
    final mySnapshot = await RainbowService().loadMyLetters();

    final loadedLetters = publicSnapshot.docs
        .map((doc) => RainbowLetter.fromDoc(doc))
        .toList();

    final loadedMyLetters = mySnapshot.docs
        .map((doc) => RainbowLetter.fromDoc(doc))
        .toList();

    if (!mounted) return;

    setState(() {
      letters = loadedLetters;
      myLetters = loadedMyLetters;
      isLoading = false;
    });
  }

  Future<void> openCreateLetterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRainbowLetterScreen()),
    );

    if (result == true) {
      await loadLetters();
    }
  }

  Widget _buildPublicLetters() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFDCA8)),
      );
    }

    if (letters.isEmpty) {
      return const _EmptyRainbowTab(
        title: '아직 도착한 편지가 없어요',
        subtitle: '첫 번째 별빛 편지를 남겨보세요.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RainbowLetterDetailScreen(letter: letter),
              ),
            );

            if (result == true) {
              await loadLetters();
            }
          },
          child: _RainbowLetterPreviewCard(
            date: _formatDate(letter.createdAt),
            title: letter.title,
            preview: letter.content,
            todakCount: letter.todakCount,
          ),
        );
      },
    );
  }

  Widget _buildMyLetters() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFDCA8)),
      );
    }

    if (myLetters.isEmpty) {
      return const _EmptyRainbowTab(
        title: '아직 쓴 편지가 없어요',
        subtitle: '아이에게 전하고 싶은 마음을 남겨보세요.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      itemCount: myLetters.length,
      itemBuilder: (context, index) {
        final letter = myLetters[index];

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RainbowLetterDetailScreen(letter: letter),
              ),
            );

            if (result == true) {
              await loadLetters();
            }
          },
          child: _RainbowLetterPreviewCard(
            date: _formatDate(letter.createdAt),
            title: letter.title,
            preview: letter.content,
            todakCount: letter.todakCount,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF10172A),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFFDCA8),
          foregroundColor: const Color(0xFF3D241E),
          elevation: 4,
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text(
            '추억 남기기',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          onPressed: openCreateLetterScreen,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                '🌈 무지개별',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '우리 아이들이 쉬고 있는 곳',
                style: TextStyle(fontSize: 15, color: Color(0xFFC7CBEA)),
              ),
              const SizedBox(height: 28),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedMessage,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFDCA8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const TabBar(
                indicatorColor: Color(0xFFFFB6D5),
                labelColor: Color(0xFFFFB6D5),
                unselectedLabelColor: Color(0xFF9EA3C7),
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: '무지개별'),
                  Tab(text: '내 편지'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_buildPublicLetters(), _buildMyLetters()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRainbowTab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyRainbowTab({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFFB8BDD8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RainbowLetterPreviewCard extends StatelessWidget {
  final String date;
  final String title;
  final String preview;
  final int todakCount;

  const _RainbowLetterPreviewCard({
    required this.date,
    required this.title,
    required this.preview,
    required this.todakCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Column(
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFFFFDCA8),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text('⭐', style: TextStyle(fontSize: 18)),
              Container(
                width: 1,
                height: 92,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white24,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB8BDD8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '🤗 토닥토닥 $todakCount',
                  style: const TextStyle(
                    color: Color(0xFFFFDCA8),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
