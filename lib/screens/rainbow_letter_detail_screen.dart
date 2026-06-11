import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/rainbow_letter.dart';
import '../models/todak_comment.dart';
import '../services/rainbow_service.dart';

class RainbowLetterDetailScreen extends StatefulWidget {
  final RainbowLetter letter;

  const RainbowLetterDetailScreen({super.key, required this.letter});

  @override
  State<RainbowLetterDetailScreen> createState() =>
      _RainbowLetterDetailScreenState();
}

class _RainbowLetterDetailScreenState extends State<RainbowLetterDetailScreen> {
  final TextEditingController todakController = TextEditingController();

  List<TodakComment> comments = [];

  bool isLoadingComments = true;
  bool isSubmitting = false;
  int currentTodakCount = 0;

  @override
  void initState() {
    super.initState();
    currentTodakCount = widget.letter.todakCount;
    loadComments();
  }

  @override
  void dispose() {
    todakController.dispose();
    super.dispose();
  }

  Future<void> loadComments() async {
    final snapshot = await RainbowService().loadTodakComments(widget.letter.id);

    final loadedComments = snapshot.docs
        .map((doc) => TodakComment.fromDoc(doc))
        .toList();

    if (!mounted) return;

    setState(() {
      comments = loadedComments;
      currentTodakCount = loadedComments.length;
      isLoadingComments = false;
    });
  }

  Future<void> submitTodak() async {
    final content = todakController.text.trim();

    if (content.isEmpty) return;
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userId = userDoc.data()?['userId'] ?? '';

      await RainbowService().addTodakComment(
        letterId: widget.letter.id,
        writerUserId: userId,
        content: content,
      );

      todakController.clear();

      if (!mounted) return;

      FocusScope.of(context).unfocus();

      await loadComments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('토닥토닥을 남기지 못했어요.')));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('편지 삭제'),
          content: const Text('정말 삭제하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await RainbowService().deleteLetter(widget.letter.id);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  String formatDateTime(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year.$month.$day $hour:$minute';
  }

  Widget buildLetterImage() {
    final imageUrl = widget.letter.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 220,
            alignment: Alignment.center,
            color: Colors.white.withValues(alpha: 0.08),
            child: const CircularProgressIndicator(color: Color(0xFFFFDCA8)),
          ),
          errorWidget: (context, url, error) => Container(
            height: 220,
            alignment: Alignment.center,
            color: Colors.white.withValues(alpha: 0.08),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Color(0xFFFFDCA8),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTodakSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤗 토닥토닥 $currentTodakCount개',
            style: const TextStyle(
              color: Color(0xFFFFDCA8),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          if (isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: Color(0xFFFFDCA8)),
              ),
            )
          else if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '아직 남겨진 토닥토닥이 없어요.',
                style: TextStyle(color: Color(0xFFB8BDD8), fontSize: 14),
              ),
            )
          else
            Column(
              children: comments.map((comment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.content,
                        style: const TextStyle(
                          color: Color(0xFFE8EAF8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '- ${comment.writerUserId} -',
                        style: const TextStyle(
                          color: Color(0xFF9EA3C7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: todakController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '따뜻한 토닥토닥을 남겨주세요.',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8F95B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitTodak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDCA8),
                  foregroundColor: const Color(0xFF3D241E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isSubmitting ? '...' : '토닥',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10172A),
        foregroundColor: Colors.white,
        title: const Text('무지개별 편지'),
        actions: [
          if (widget.letter.ownerUid == FirebaseAuth.instance.currentUser?.uid)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  await showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            '@${widget.letter.ownerUserId}',
            style: const TextStyle(
              color: Color(0xFFFFDCA8),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatDateTime(widget.letter.createdAt),
            style: const TextStyle(color: Color(0xFF9EA3C7), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Text(
            widget.letter.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.letter.catName}에게',
            style: const TextStyle(
              color: Color(0xFFFFB6D5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          buildLetterImage(),
          const SizedBox(height: 28),
          Text(
            widget.letter.content,
            style: const TextStyle(
              color: Color(0xFFE8EAF8),
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 36),
          buildTodakSection(),
        ],
      ),
    );
  }
}
