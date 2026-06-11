import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/rainbow_letter.dart';
import '../models/todak_comment.dart';
import '../services/rainbow_service.dart';
import '../services/report_service.dart';

class RainbowLetterDetailScreen extends StatefulWidget {
  final RainbowLetter letter;

  const RainbowLetterDetailScreen({super.key, required this.letter});

  @override
  State<RainbowLetterDetailScreen> createState() =>
      _RainbowLetterDetailScreenState();
}

class _RainbowLetterDetailScreenState extends State<RainbowLetterDetailScreen> {
  final TextEditingController todakController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  List<TodakComment> comments = [];

  bool isLoadingComments = true;
  bool isSubmitting = false;
  bool isUpdatingImage = false;
  int currentTodakCount = 0;

  late String currentTitle;
  late String currentCatName;
  late String currentContent;
  String? currentImageUrl;
  String? currentImageStoragePath;

  @override
  void initState() {
    super.initState();

    currentTitle = widget.letter.title;
    currentCatName = widget.letter.catName;
    currentContent = widget.letter.content;
    currentImageUrl = widget.letter.imageUrl;
    currentImageStoragePath = widget.letter.imageStoragePath;

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

  Future<void> showEditLetterDialog() async {
    final titleController = TextEditingController(text: currentTitle);
    final catNameController = TextEditingController(text: currentCatName);
    final contentController = TextEditingController(text: currentContent);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF18213A),
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '편지 수정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _EditField(
                    controller: titleController,
                    label: '제목',
                    hintText: '제목을 입력해주세요.',
                  ),
                  const SizedBox(height: 14),
                  _EditField(
                    controller: catNameController,
                    label: '아이 이름',
                    hintText: '아이 이름을 입력해주세요.',
                  ),
                  const SizedBox(height: 14),
                  _EditField(
                    controller: contentController,
                    label: '내용',
                    hintText: '전하고 싶은 마음을 적어주세요.',
                    maxLines: 7,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          child: const Text(
                            '취소',
                            style: TextStyle(color: Color(0xFFB8BDD8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty ||
                                catNameController.text.trim().isEmpty ||
                                contentController.text.trim().isEmpty) {
                              return;
                            }

                            Navigator.pop(dialogContext, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFDCA8),
                            foregroundColor: const Color(0xFF3D241E),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '수정',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != true) return;

    final newTitle = titleController.text.trim();
    final newCatName = catNameController.text.trim();
    final newContent = contentController.text.trim();

    await RainbowService().updateLetter(
      letterId: widget.letter.id,
      title: newTitle,
      catName: newCatName,
      content: newContent,
    );

    if (!mounted) return;

    setState(() {
      currentTitle = newTitle;
      currentCatName = newCatName;
      currentContent = newContent;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('편지가 수정되었습니다.')));
  }

  Future<CropAspectRatio?> selectImageRatio() {
    return showModalBottomSheet<CropAspectRatio>(
      context: context,
      backgroundColor: const Color(0xFF10172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '사진 비율 선택',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.crop_landscape_rounded,
                    color: Color(0xFFFFDCA8),
                  ),
                  title: const Text(
                    '가로형 4:3',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      const CropAspectRatio(ratioX: 4, ratioY: 3),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.crop_portrait_rounded,
                    color: Color(0xFFFFDCA8),
                  ),
                  title: const Text(
                    '세로형 4:5',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      const CropAspectRatio(ratioX: 4, ratioY: 5),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.crop_square_rounded,
                    color: Color(0xFFFFDCA8),
                  ),
                  title: const Text(
                    '정사각형 1:1',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      const CropAspectRatio(ratioX: 1, ratioY: 1),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateLetterImage() async {
    if (isUpdatingImage) return;

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (!mounted) return;

    final selectedRatio = await selectImageRatio();
    if (selectedRatio == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: selectedRatio,
    );

    if (croppedFile == null) return;

    setState(() {
      isUpdatingImage = true;
    });

    try {
      final result = await RainbowService().updateLetterImage(
        letterId: widget.letter.id,
        ownerUid: widget.letter.ownerUid,
        oldImageStoragePath: currentImageStoragePath,
        imageFile: File(croppedFile.path),
      );

      if (!mounted) return;

      setState(() {
        currentImageUrl = result['imageUrl'];
        currentImageStoragePath = result['imageStoragePath'];
        isUpdatingImage = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진이 수정되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUpdatingImage = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진 수정 중 오류가 발생했어요.')));
    }
  }

  Future<void> showReportDialog() async {
    try {
      await ReportService.createReport(
        targetType: 'rainbowLetter',
        targetId: widget.letter.id,
        targetOwnerUid: widget.letter.ownerUid,
        reason: '무지개별 편지 신고',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().contains('이미 신고한 항목')
          ? '이미 신고한 편지예요.'
          : '신고 접수 중 오류가 발생했어요.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> reportTodakComment(TodakComment comment) async {
    try {
      await ReportService.createReport(
        targetType: 'todakComment',
        targetId: comment.id,
        targetOwnerUid: comment.writerUid,
        reason: '토닥토닥 신고',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().contains('이미 신고한 항목')
          ? '이미 신고한 토닥토닥이에요.'
          : '신고 접수 중 오류가 발생했어요.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> showEditTodakDialog(TodakComment comment) async {
    final controller = TextEditingController(text: comment.content);

    final editedContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('토닥토닥 수정'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(hintText: '토닥토닥을 수정해 주세요.'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final content = controller.text.trim();
                if (content.isEmpty) return;

                Navigator.pop(dialogContext, content);
              },
              child: const Text('수정'),
            ),
          ],
        );
      },
    );

    if (editedContent == null) return;

    await RainbowService().updateTodakComment(
      letterId: widget.letter.id,
      commentId: comment.id,
      content: editedContent,
    );

    await loadComments();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('토닥토닥이 수정되었습니다.')));
  }

  Future<void> deleteTodakComment(TodakComment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('토닥토닥 삭제'),
          content: const Text('토닥토닥을 삭제할까요?'),
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

    if (confirm != true) return;

    await RainbowService().deleteTodakComment(
      letterId: widget.letter.id,
      commentId: comment.id,
    );

    await loadComments();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('토닥토닥이 삭제되었습니다.')));
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
    final imageUrl = currentImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 220,
                alignment: Alignment.center,
                color: Colors.white.withValues(alpha: 0.08),
                child: const CircularProgressIndicator(
                  color: Color(0xFFFFDCA8),
                ),
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
          if (isUpdatingImage)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFFFFDCA8),
                ),
              ),
            ),
        ],
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
                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                final isMyComment = comment.writerUid == currentUid;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: comment.content,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFE8EAF8),
                                        ),
                                      ),
                                      TextSpan(
                                        text: '  -${comment.writerUserId}-',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9EA3C7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.updatedAt != null
                                      ? '${formatDateTime(comment.createdAt)} · 수정됨'
                                      : formatDateTime(comment.createdAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9EA3C7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert,
                              size: 16,
                              color: Color(0xFF9EA3C7),
                            ),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await showEditTodakDialog(comment);
                              } else if (value == 'delete') {
                                await deleteTodakComment(comment);
                              } else if (value == 'report') {
                                await reportTodakComment(comment);
                              }
                            },
                            itemBuilder: (context) {
                              if (isMyComment) {
                                return const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('수정'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('삭제'),
                                  ),
                                ];
                              }

                              return const [
                                PopupMenuItem(
                                  value: 'report',
                                  child: Text('신고'),
                                ),
                              ];
                            },
                          ),
                        ],
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
    final isMyLetter =
        widget.letter.ownerUid == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF10172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10172A),
        foregroundColor: Colors.white,
        title: const Text('무지개별 편지'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await showEditLetterDialog();
              } else if (value == 'image') {
                await updateLetterImage();
              } else if (value == 'delete') {
                await showDeleteDialog();
              } else if (value == 'report') {
                await showReportDialog();
              }
            },
            itemBuilder: (context) {
              if (isMyLetter) {
                return const [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'image', child: Text('사진 수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ];
              }

              return const [PopupMenuItem(value: 'report', child: Text('신고'))];
            },
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
            currentTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentCatName에게',
            style: const TextStyle(
              color: Color(0xFFFFB6D5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          buildLetterImage(),
          const SizedBox(height: 28),
          Text(
            currentContent,
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

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLines;

  const _EditField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Color(0xFFFFDCA8)),
        hintStyle: const TextStyle(color: Color(0xFF8F95B8), fontSize: 13),
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
    );
  }
}
