import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/review.dart';
import '../services/review_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/report_service.dart';

class PostDetailDialog extends StatefulWidget {
  final String imageUrl;
  final String catName;
  final String caption;
  final String tagText;
  final String postId;
  final DateTime createdAt;
  final bool canWriteReview;

  final bool showScrapButton;
  final bool isScrapped;
  final Future<void> Function()? onScrapTap;
  final bool showMoreButton;
  final VoidCallback? onMoreTap;

  const PostDetailDialog({
    super.key,
    required this.imageUrl,
    required this.catName,
    required this.caption,
    required this.tagText,
    required this.postId,
    required this.createdAt,
    this.canWriteReview = false,
    this.showScrapButton = false,
    this.isScrapped = false,
    this.onScrapTap,
    this.showMoreButton = false,
    this.onMoreTap,
  });

  @override
  State<PostDetailDialog> createState() => _PostDetailDialogState();
}

class _PostDetailDialogState extends State<PostDetailDialog> {
  final TextEditingController reviewController = TextEditingController();

  List<Review> reviews = [];
  bool isLoadingReviews = true;
  bool isSubmittingReview = false;
  bool isHandlingScrap = false;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> loadReviews() async {
    final loadedReviews = await ReviewService.loadReviews(widget.postId);

    if (!mounted) return;

    setState(() {
      reviews = loadedReviews;
      isLoadingReviews = false;
    });
  }

  Future<void> submitReview() async {
    final content = reviewController.text.trim();

    if (content.isEmpty) return;
    if (isSubmittingReview) return;

    setState(() {
      isSubmittingReview = true;
    });

    try {
      await ReviewService.createReview(postId: widget.postId, content: content);

      if (!mounted) return;

      FocusScope.of(context).unfocus();

      reviewController.clear();
      await loadReviews();

      if (!mounted) return;

      setState(() {
        isSubmittingReview = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmittingReview = false;
      });

      final message = e.toString().contains('정지된 계정')
          ? '정지된 계정은 감상평을 작성할 수 없어요.'
          : '감상평 등록 중 오류가 발생했어요.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> handleScrapTap() async {
    if (isHandlingScrap) return;
    if (widget.onScrapTap == null) return;

    setState(() {
      isHandlingScrap = true;
    });

    await widget.onScrapTap!();

    if (!mounted) return;

    setState(() {
      isHandlingScrap = false;
    });
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}.'
        '${dateTime.month.toString().padLeft(2, '0')}.'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget buildReviewInput() {
    if (!widget.canWriteReview) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: reviewController,
              minLines: 1,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF5A372F)),
              decoration: InputDecoration(
                hintText: '감상평을 남겨보세요',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFC7ADA4),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFF3E3DA),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFF3E3DA),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8A58A),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSubmittingReview ? null : submitReview,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSubmittingReview
                    ? const Color(0xFFE7D4CB)
                    : const Color(0xFFFFC4A3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isSubmittingReview
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '등록',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A4B3A),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> reportReview(Review review) async {
    try {
      await ReportService.createReport(
        targetType: 'review',
        targetId: review.id,
        postId: widget.postId,
        targetOwnerUid: review.writerUid,
        reason: '감상평 신고',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
    } catch (e) {
      debugPrint('REPORT ERROR: $e');

      final message = e.toString().contains('이미 신고한 항목')
          ? '이미 신고한 감상평이에요.'
          : '신고 접수 중 오류가 발생했어요.';

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> showEditReviewDialog(Review review) async {
    final controller = TextEditingController(text: review.content);

    final editedContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF7F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '감상평 수정',
            style: TextStyle(
              color: Color(0xFF5C4033),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    cursorColor: const Color(0xFF8A5A44),
                    maxLines: 2,
                    maxLength: 200,
                    style: const TextStyle(
                      color: Color(0xFF5A372F),
                      fontSize: 15,
                    ),
                    onChanged: (_) {
                      setDialogState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: '감상평을 수정해 주세요.',
                      counterText: '',
                      hintStyle: const TextStyle(color: Color(0xFFC9B8AE)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8A58A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${controller.text.length}/200',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A756C),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF8A756C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final content = controller.text.trim();
                if (content.isEmpty) return;
                Navigator.pop(dialogContext, content);
              },
              child: const Text(
                '수정',
                style: TextStyle(
                  color: Color(0xFFE8A58A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (editedContent == null) return;

    await ReviewService().updateReview(
      postId: widget.postId,
      reviewId: review.id,
      content: editedContent,
    );

    await loadReviews();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('감상평이 수정되었습니다.')));
  }

  Future<void> deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '감상평 삭제',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D1B16),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  '감상평을 삭제할까요?\n삭제 후에는 복구할 수 없어요.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Color(0xFF5C4033),
                  ),
                ),

                const SizedBox(height: 36),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, false);
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Color(0xFF8A756C),
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, true);
                      },
                      child: const Text(
                        '삭제',
                        style: TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    await ReviewService().deleteReview(
      postId: widget.postId,
      reviewId: review.id,
    );

    await loadReviews();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('감상평이 삭제되었습니다.')));
  }

  Widget buildReviewList() {
    if (isLoadingReviews) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (reviews.isEmpty) {
      return const Text(
        '아직 감상평이 없어요 🐾',
        style: TextStyle(fontSize: 12, color: Color(0xFFBFA79F)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reviews.map((review) {
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final isMyReview = review.writerUid == currentUid;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
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
                                text: review.content,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5A372F),
                                ),
                              ),
                              TextSpan(
                                text: '  -${review.writerUserId}-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFBFA79F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.updatedAt != null
                              ? '${formatDate(review.createdAt ?? DateTime.now())} · 수정됨'
                              : formatDate(review.createdAt ?? DateTime.now()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFBFA79F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: 24,
                    height: 22,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFFFFF7F1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (bottomSheetContext) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  14,
                                  20,
                                  24,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isMyReview) ...[
                                      ListTile(
                                        leading: const Icon(
                                          Icons.edit_outlined,
                                          color: Color(0xFF8A756C),
                                        ),
                                        title: const Text(
                                          '감상평 수정',
                                          style: TextStyle(
                                            color: Color(0xFF5C4033),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(bottomSheetContext);
                                          showEditReviewDialog(review);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFFF7F7F),
                                        ),
                                        title: const Text(
                                          '감상평 삭제',
                                          style: TextStyle(
                                            color: Color(0xFFFF7F7F),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(bottomSheetContext);
                                          deleteReview(review);
                                        },
                                      ),
                                    ] else ...[
                                      ListTile(
                                        leading: const Icon(
                                          Icons.flag_outlined,
                                          color: Color(0xFFFF7F7F),
                                        ),
                                        title: const Text(
                                          '감상평 신고',
                                          style: TextStyle(
                                            color: Color(0xFFFF7F7F),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(bottomSheetContext);
                                          reportReview(review);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.more_vert,
                        size: 16,
                        color: Color(0xFFC0A39A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 0.5, color: const Color(0xFFF1E6E1)),
          ],
        );
      }).toList(),
    );
  }

  Widget buildScrapButton() {
    if (!widget.showScrapButton) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: isHandlingScrap ? null : handleScrapTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Center(
          child: isHandlingScrap
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.isScrapped
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 22,
                  color: widget.isScrapped
                      ? const Color(0xFFFF8A7A)
                      : const Color(0xFFB08678),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 260,
                    alignment: Alignment.center,
                    color: const Color(0xFFFFF3E7),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 260,
                    alignment: Alignment.center,
                    color: const Color(0xFFFFF3E7),
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.catName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5A372F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        if (widget.showMoreButton)
                          GestureDetector(
                            onTap: widget.onMoreTap,
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox(
                              width: 34,
                              height: 34,
                              child: Center(
                                child: Icon(
                                  Icons.more_horiz,
                                  size: 22,
                                  color: Color(0xFFB08678),
                                ),
                              ),
                            ),
                          ),

                        if (widget.showMoreButton && widget.showScrapButton)
                          const SizedBox(width: 8),

                        buildScrapButton(),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      formatDate(widget.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBFA79F),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.caption,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A372F),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.tagText,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE09086),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      '감상평',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A372F),
                      ),
                    ),

                    const SizedBox(height: 10),

                    buildReviewInput(),

                    buildReviewList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
