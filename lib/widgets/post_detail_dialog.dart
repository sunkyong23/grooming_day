import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class PostDetailDialog extends StatefulWidget {
  final String imageUrl;
  final String catName;
  final String caption;
  final String tagText;
  final String postId;
  final DateTime createdAt;

  const PostDetailDialog({
    super.key,
    required this.imageUrl,
    required this.catName,
    required this.caption,
    required this.tagText,
    required this.postId,
    required this.createdAt,
  });

  @override
  State<PostDetailDialog> createState() => _PostDetailDialogState();
}

class _PostDetailDialogState extends State<PostDetailDialog> {
  List<Review> reviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    final loadedReviews = await ReviewService.loadReviews(widget.postId);

    if (!mounted) return;

    setState(() {
      reviews = loadedReviews;
      isLoadingReviews = false;
    });
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}.'
        '${dateTime.month.toString().padLeft(2, '0')}.'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
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
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                        Text(
                          formatDate(widget.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFBFA79F),
                          ),
                        ),
                      ],
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

                    const SizedBox(height: 20),

                    const Text(
                      '감상평',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A372F),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (isLoadingReviews)
                      const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (reviews.isEmpty)
                      const Text(
                        '아직 감상평이 없어요 🐾',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBFA79F),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: reviews.map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                                        : formatDate(
                                            review.createdAt ?? DateTime.now(),
                                          ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFBFA79F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
