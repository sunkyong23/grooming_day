import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review.dart';
import '../services/review_service.dart';

class CatPostCard extends StatefulWidget {
  final String imagePath;
  final String caption;
  final String tagText;
  final DateTime createdAt;
  final String catName;
  final String userId;
  final bool isScrapped;
  final bool showMoreButton;
  final int scrapCount;
  final VoidCallback? onScrapTap;
  final VoidCallback? onMoreTap;
  final String catProfileImageUrl;
  final bool isVirtualCat;
  final int commentCount;
  final String postId;
  final bool canWriteReview;

  const CatPostCard({
    super.key,
    required this.imagePath,
    required this.caption,
    required this.tagText,
    required this.scrapCount,
    required this.createdAt,
    required this.catName,
    required this.userId,
    required this.isScrapped,
    this.showMoreButton = false,
    required this.onScrapTap,
    this.onMoreTap,
    required this.catProfileImageUrl,
    required this.isVirtualCat,
    required this.commentCount,
    required this.postId,
    this.canWriteReview = true,
  });

  @override
  State<CatPostCard> createState() => _CatPostCardState();
}

class _CatPostCardState extends State<CatPostCard> {
  bool isReviewExpanded = false;
  bool isSubmittingReview = false;
  bool isLoadingReviews = false;
  late int currentCommentCount;

  List<Review> reviews = [];
  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentCommentCount = widget.commentCount;
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  String formatReviewDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadReviews() async {
    setState(() {
      isLoadingReviews = true;
    });

    final loadedReviews = await ReviewService.loadReviews(widget.postId);

    if (!mounted) return;

    setState(() {
      reviews = loadedReviews;
      currentCommentCount = loadedReviews.length;
      isLoadingReviews = false;
    });
  }

  Future<void> showEditReviewDialog(Review review) async {
    final controller = TextEditingController(text: review.content);

    final editedContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('감상평 수정'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(hintText: '감상평을 수정해 주세요.'),
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

    await ReviewService().updateReview(
      postId: widget.postId,
      reviewId: review.id,
      content: editedContent,
    );

    if (!mounted) return;

    setState(() {
      final index = reviews.indexWhere((item) => item.id == review.id);

      if (index != -1) {
        reviews[index] = Review(
          id: review.id,
          postId: review.postId,
          writerUid: review.writerUid,
          writerUserId: review.writerUserId,
          content: editedContent,
          createdAt: review.createdAt,
          updatedAt: DateTime.now(),
          isDeleted: review.isDeleted,
        );
      }
    });
  }

  Future<void> deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('감상평 삭제'),
          content: const Text('감상평을 삭제할까요?'),
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

    await ReviewService().deleteReview(
      postId: widget.postId,
      reviewId: review.id,
    );

    if (!mounted) return;

    setState(() {
      reviews.removeWhere((item) => item.id == review.id);
      currentCommentCount = currentCommentCount > 0
          ? currentCommentCount - 1
          : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFFFE2C6),
                  backgroundImage: widget.catProfileImageUrl.isNotEmpty
                      ? NetworkImage(widget.catProfileImageUrl)
                      : null,
                  child: widget.catProfileImageUrl.isEmpty
                      ? (widget.isVirtualCat
                            ? Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(
                                  'assets/icons/today_cat.png',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Text('🐱', style: TextStyle(fontSize: 17)))
                      : null,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.catName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3D241E),
                        ),
                      ),
                      Text(
                        '@${widget.userId}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB08678),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${widget.createdAt.year}.${widget.createdAt.month.toString().padLeft(2, '0')}.${widget.createdAt.day.toString().padLeft(2, '0')} · ${widget.createdAt.hour.toString().padLeft(2, '0')}:${widget.createdAt.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 9, color: Color(0xFFC9AFA7)),
                ),
                const SizedBox(width: 12),
                if (widget.showMoreButton)
                  GestureDetector(
                    onTap: widget.onMoreTap,
                    child: const Icon(
                      Icons.more_horiz,
                      size: 21,
                      color: Color(0xFF9A6B60),
                    ),
                  ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                builder: (_) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.imagePath,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              '이미지를 불러오지 못했어요 🐾',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                widget.imagePath,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 260,
                    alignment: Alignment.center,
                    color: const Color(0xFFFFF3E7),
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 260,
                    alignment: Alignment.center,
                    color: const Color(0xFFFFF3E7),
                    child: const Text('이미지를 불러오지 못했어요 🐾'),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.caption,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A372F),
                        ),
                      ),
                    ),
                    if (widget.onScrapTap != null)
                      GestureDetector(
                        onTap: widget.onScrapTap,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: widget.isScrapped ? 1.15 : 1.0,
                          child: Icon(
                            widget.isScrapped
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: widget.isScrapped
                                ? const Color(0xFFFF8A7A)
                                : const Color(0xFFC9B8AF),
                            size: 23,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isReviewExpanded = !isReviewExpanded;
                        });

                        if (isReviewExpanded) {
                          await loadReviews();
                        }
                      },
                      child: Text(
                        currentCommentCount == 0
                            ? '감상평'
                            : '감상평 $currentCommentCount개',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFC0A39A),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.tagText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE09086),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                if (isReviewExpanded) ...[
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        if (widget.canWriteReview) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: reviewController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: '감상평을 남겨보세요 🐾',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFBFA79F),
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
                                        color: Color(0xFFFFD7B8),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              ElevatedButton(
                                onPressed: isSubmittingReview
                                    ? null
                                    : () async {
                                        setState(() {
                                          isSubmittingReview = true;
                                        });

                                        try {
                                          final newReview =
                                              await ReviewService.createReview(
                                                postId: widget.postId,
                                                content: reviewController.text,
                                              );

                                          if (newReview == null) return;

                                          reviewController.clear();

                                          FocusScope.of(context).unfocus();

                                          setState(() {
                                            currentCommentCount += 1;
                                            reviews.insert(0, newReview);
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('따뜻한 감상평 고마워요 🐾'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              isSubmittingReview = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD7B8),
                                  foregroundColor: const Color(0xFF8A5A44),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isSubmittingReview ? '중...' : '등록',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                        ],

                        if (isLoadingReviews)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (reviews
                            .where((review) => review.content.trim().isNotEmpty)
                            .isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              widget.canWriteReview
                                  ? '아직 등록된 감상평이 없어요 🐾'
                                  : '아직 받은 감상평이 없어요 🐾',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9A6B60),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: reviews
                                .where(
                                  (review) => review.content.trim().isNotEmpty,
                                )
                                .map((review) {
                                  final currentUid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  final isMyReview =
                                      review.writerUid == currentUid;

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: review.content,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                  0xFF5A372F,
                                                                ),
                                                              ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '  -${review.writerUserId}-',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(
                                                                  0xFFBFA79F,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                if (isMyReview)
                                                  SizedBox(
                                                    width: 24,
                                                    height: 22,
                                                    child: PopupMenuButton<String>(
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 28,
                                                            minHeight: 28,
                                                          ),
                                                      iconSize: 14,
                                                      icon: const Icon(
                                                        Icons.more_vert,
                                                        size: 14,
                                                        color: Color(
                                                          0xFFC0A39A,
                                                        ),
                                                      ),
                                                      onSelected: (value) async {
                                                        await Future.delayed(
                                                          const Duration(
                                                            milliseconds: 150,
                                                          ),
                                                        );

                                                        if (!mounted) return;

                                                        if (value == 'edit') {
                                                          showEditReviewDialog(
                                                            review,
                                                          );
                                                        } else if (value ==
                                                            'delete') {
                                                          deleteReview(review);
                                                        }
                                                      },
                                                      itemBuilder: (context) =>
                                                          const [
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Text('수정'),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'delete',
                                                              child: Text('삭제'),
                                                            ),
                                                          ],
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            const SizedBox(height: 3),

                                            Text(
                                              review.createdAt == null
                                                  ? ''
                                                  : review.updatedAt != null
                                                  ? '${formatReviewDate(review.createdAt!)} · 수정됨'
                                                  : formatReviewDate(
                                                      review.createdAt!,
                                                    ),
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Color(0xFFC8B7AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        height: 0.5,
                                        color: const Color(0xFFF1E6E1),
                                      ),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
