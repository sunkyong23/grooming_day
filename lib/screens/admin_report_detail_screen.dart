import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../widgets/post_detail_dialog.dart';

class AdminReportDetailScreen extends StatelessWidget {
  final String reportId;
  final Map<String, dynamic> reportData;

  const AdminReportDetailScreen({
    super.key,
    required this.reportId,
    required this.reportData,
  });

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();

    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'resolved':
        return '처리 완료';
      case 'rejected':
        return '반려';
      default:
        return '대기중';
    }
  }

  Future<void> updateReportStatus({required String status}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .update({
          'status': status,
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': currentUser?.uid,
        });
  }

  Future<void> hideOriginalPost(BuildContext context) async {
    final targetType = reportData['targetType'] as String? ?? '';
    final targetId = reportData['targetId'] as String? ?? '';
    final savedPostId = reportData['postId'] as String?;

    final postId = savedPostId ?? (targetType == 'post' ? targetId : '');

    if (postId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('숨김 처리할 게시글 ID를 찾을 수 없어요.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('게시글 숨김 처리'),
          content: const Text('이 게시글을 숨김 처리할까요?\n홈/검색/앨범에서 노출되지 않게 됩니다.'),
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
              child: const Text('숨김 처리'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'isHidden': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await updateReportStatus(status: 'resolved');

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('게시글을 숨김 처리하고 신고를 처리 완료했어요.')));

    Navigator.pop(context);
  }

  Future<void> hideReportedReview(BuildContext context) async {
    final targetType = reportData['targetType'] as String? ?? '';
    final reviewId = reportData['targetId'] as String? ?? '';
    final postId = reportData['postId'] as String? ?? '';

    if (targetType != 'review') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('감상평 신고가 아니에요.')));
      return;
    }

    if (postId.isEmpty || reviewId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('숨김 처리할 감상평 정보를 찾을 수 없어요.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('감상평 숨김 처리'),
          content: const Text('이 감상평을 숨김 처리할까요?\n사용자 화면에서 노출되지 않게 됩니다.'),
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
              child: const Text('숨김 처리'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final reviewRef = postRef.collection('reviews').doc(reviewId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      final reviewSnapshot = await transaction.get(reviewRef);

      if (!postSnapshot.exists || !reviewSnapshot.exists) {
        return;
      }

      final postData = postSnapshot.data() ?? {};
      final reviewData = reviewSnapshot.data() ?? {};

      final currentCommentCount =
          (postData['commentCount'] as num?)?.toInt() ?? 0;

      final alreadyHidden = reviewData['isHidden'] == true;

      transaction.update(reviewRef, {
        'isHidden': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!alreadyHidden) {
        transaction.update(postRef, {
          'commentCount': currentCommentCount > 0 ? currentCommentCount - 1 : 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    await updateReportStatus(status: 'resolved');

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('감상평을 숨김 처리하고 신고를 처리 완료했어요.')));

    Navigator.pop(context);
  }

  Future<void> showOriginalPost(BuildContext context) async {
    final targetType = reportData['targetType'] as String? ?? '';
    final targetId = reportData['targetId'] as String? ?? '';
    final savedPostId = reportData['postId'] as String?;

    final postId = savedPostId ?? (targetType == 'post' ? targetId : '');

    if (postId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원본 게시글 ID를 찾을 수 없어요.')));
      return;
    }

    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    if (!context.mounted) return;

    if (!postDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원본 게시글이 삭제되었거나 존재하지 않아요.')));
      return;
    }

    final post = Post.fromDoc(postDoc);
    final tagText = post.tags.map((tag) => '#$tag').join(' ');

    showDialog(
      context: context,
      builder: (_) {
        return PostDetailDialog(
          imageUrl: post.imageUrl,
          catName: post.catName,
          caption: post.caption,
          tagText: tagText,
          postId: post.id,
          createdAt: post.createdAt ?? DateTime.now(),
          canWriteReview: false,
          showScrapButton: false,
          showMoreButton: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetType = reportData['targetType'] as String? ?? '';
    final reason = reportData['reason'] as String? ?? '';
    final description = reportData['description'] as String? ?? '';
    final reporterUserId = reportData['reporterUserId'] as String? ?? '';
    final targetId = reportData['targetId'] as String? ?? '';
    final postId = reportData['postId'] as String? ?? '';
    final targetOwnerUid = reportData['targetOwnerUid'] as String? ?? '';
    final status = reportData['status'] as String? ?? 'pending';
    final createdAt = reportData['createdAt'] as Timestamp?;

    final typeText = targetType == 'review'
        ? '감상평 신고'
        : targetType == 'post'
        ? '게시글 신고'
        : '기타 신고';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text('신고 상세', style: TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoCard(
            title: typeText,
            children: [
              _row('상태', statusText(status)),
              _row('신고 사유', reason.isEmpty ? '없음' : reason),
              _row('상세 내용', description.isEmpty ? '없음' : description),
              _row(
                '신고자',
                reporterUserId.isEmpty ? '알 수 없음' : '@$reporterUserId',
              ),
              _row('신고일', formatDate(createdAt)),
              _row('대상 ID', targetId.isEmpty ? '없음' : targetId),
              _row('게시글 ID', postId.isEmpty ? '없음' : postId),
              _row(
                '대상 소유자 UID',
                targetOwnerUid.isEmpty ? '없음' : targetOwnerUid,
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showOriginalPost(context),
              icon: const Icon(Icons.article_outlined, size: 18),
              label: const Text('원본 게시글 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5C4033),
                side: const BorderSide(color: Color(0xFFD8B7A8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await hideOriginalPost(context);
              },
              icon: const Icon(Icons.visibility_off_outlined, size: 18),
              label: const Text('게시글 숨김 처리'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A7A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (targetType == 'review') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await hideReportedReview(context);
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('감상평 숨김 처리'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE09086),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await updateReportStatus(status: 'resolved');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고를 처리 완료했어요.')),
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4033),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '처리 완료',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await updateReportStatus(status: 'rejected');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고를 반려했어요.')),
                      );

                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5C4033),
                      side: const BorderSide(color: Color(0xFF5C4033)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '반려',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D241E),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFB08678),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5C4033),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
