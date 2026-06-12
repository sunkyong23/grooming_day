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

  String formatDateFromDynamic(dynamic value) {
    if (value is Timestamp) {
      return formatDate(value);
    }
    return '';
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

  String typeText(String targetType) {
    switch (targetType) {
      case 'post':
        return '게시글 신고';
      case 'review':
        return '감상평 신고';
      case 'rainbowLetter':
        return '무지개별 편지 신고';
      case 'todakComment':
        return '토닥토닥 신고';
      default:
        return '기타 신고';
    }
  }

  String originalButtonText(String targetType) {
    switch (targetType) {
      case 'rainbowLetter':
        return '원본 편지 보기';
      case 'todakComment':
        return '원본 토닥토닥 보기';
      default:
        return '원본 게시글 보기';
    }
  }

  String hideButtonText(String targetType) {
    switch (targetType) {
      case 'rainbowLetter':
        return '편지 숨김 처리';
      case 'todakComment':
        return '토닥토닥 숨김 처리';
      default:
        return '게시글 숨김 처리';
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

  Future<void> hideOriginalContent(BuildContext context) async {
    final targetType = reportData['targetType'] as String? ?? '';

    if (targetType == 'review') {
      await hideReportedReview(context);
      return;
    }

    if (targetType == 'rainbowLetter') {
      await hideRainbowLetter(context);
      return;
    }

    if (targetType == 'todakComment') {
      await hideTodakComment(context);
      return;
    }

    await hideOriginalPost(context);
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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

      if (!postSnapshot.exists || !reviewSnapshot.exists) return;

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

  Future<void> hideRainbowLetter(BuildContext context) async {
    final targetId = reportData['targetId'] as String? ?? '';
    final letterId = reportData['letterId'] as String? ?? targetId;

    if (letterId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('숨김 처리할 편지 ID를 찾을 수 없어요.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('무지개별 편지 숨김 처리'),
          content: const Text('이 편지를 숨김 처리할까요?\n무지개별에서 노출되지 않게 됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('숨김 처리'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('rainbowLetters')
        .doc(letterId)
        .update({'isHidden': true, 'updatedAt': FieldValue.serverTimestamp()});

    await updateReportStatus(status: 'resolved');

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('편지를 숨김 처리하고 신고를 처리 완료했어요.')));

    Navigator.pop(context);
  }

  Future<void> hideTodakComment(BuildContext context) async {
    final targetId = reportData['targetId'] as String? ?? '';
    final letterId = reportData['letterId'] as String? ?? '';
    final commentId = reportData['commentId'] as String? ?? targetId;

    if (letterId.isEmpty || commentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('숨김 처리할 토닥토닥 정보를 찾을 수 없어요.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('토닥토닥 숨김 처리'),
          content: const Text('이 토닥토닥을 숨김 처리할까요?\n사용자 화면에서 노출되지 않게 됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('숨김 처리'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final letterRef = FirebaseFirestore.instance
        .collection('rainbowLetters')
        .doc(letterId);

    final commentRef = letterRef.collection('todakComments').doc(commentId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final letterSnapshot = await transaction.get(letterRef);
      final commentSnapshot = await transaction.get(commentRef);

      if (!letterSnapshot.exists || !commentSnapshot.exists) return;

      final letterData = letterSnapshot.data() ?? {};
      final commentData = commentSnapshot.data() ?? {};

      final currentTodakCount =
          (letterData['todakCount'] as num?)?.toInt() ?? 0;

      final alreadyHidden = commentData['isHidden'] == true;

      transaction.update(commentRef, {
        'isHidden': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!alreadyHidden) {
        transaction.update(letterRef, {
          'todakCount': currentTodakCount > 0 ? currentTodakCount - 1 : 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    await updateReportStatus(status: 'resolved');

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('토닥토닥을 숨김 처리하고 신고를 처리 완료했어요.')),
    );

    Navigator.pop(context);
  }

  Future<void> showOriginalContent(BuildContext context) async {
    final targetType = reportData['targetType'] as String? ?? '';

    if (targetType == 'rainbowLetter') {
      await showOriginalRainbowLetter(context);
      return;
    }

    if (targetType == 'todakComment') {
      await showOriginalTodakComment(context);
      return;
    }

    await showOriginalPost(context);
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

  Future<void> showOriginalRainbowLetter(BuildContext context) async {
    final targetId = reportData['targetId'] as String? ?? '';
    final letterId = reportData['letterId'] as String? ?? targetId;

    if (letterId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원본 편지 ID를 찾을 수 없어요.')));
      return;
    }

    final letterDoc = await FirebaseFirestore.instance
        .collection('rainbowLetters')
        .doc(letterId)
        .get();

    if (!context.mounted) return;

    if (!letterDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원본 편지가 삭제되었거나 존재하지 않아요.')));
      return;
    }

    final data = letterDoc.data() ?? {};

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF0B113A),
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '원본 무지개별 편지',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '@${data['ownerUserId'] ?? ''}',
                  style: const TextStyle(
                    color: Color(0xFFFFDCA8),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDateFromDynamic(data['createdAt']),
                  style: const TextStyle(
                    color: Color(0xFF9EA3C7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data['catName'] ?? ''}에게',
                  style: const TextStyle(
                    color: Color(0xFFFFB6D5),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data['content'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFFE8EAF8),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: Color(0xFFFFDCA8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showOriginalTodakComment(BuildContext context) async {
    final targetId = reportData['targetId'] as String? ?? '';
    final letterId = reportData['letterId'] as String? ?? '';
    final commentId = reportData['commentId'] as String? ?? targetId;

    if (letterId.isEmpty || commentId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원본 토닥토닥 정보를 찾을 수 없어요.')));
      return;
    }

    final letterDoc = await FirebaseFirestore.instance
        .collection('rainbowLetters')
        .doc(letterId)
        .get();

    final commentDoc = await FirebaseFirestore.instance
        .collection('rainbowLetters')
        .doc(letterId)
        .collection('todakComments')
        .doc(commentId)
        .get();

    if (!context.mounted) return;

    if (!letterDoc.exists || !commentDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원본 토닥토닥이 삭제되었거나 존재하지 않아요.')),
      );
      return;
    }

    final letterData = letterDoc.data() ?? {};
    final commentData = commentDoc.data() ?? {};

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF0B113A),
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '원본 토닥토닥',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '편지',
                  style: TextStyle(
                    color: Color(0xFFFFDCA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  letterData['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '토닥토닥 내용',
                  style: TextStyle(
                    color: Color(0xFFFFDCA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  commentData['content'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFFE8EAF8),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '@${commentData['writerUserId'] ?? ''} · ${formatDateFromDynamic(commentData['createdAt'])}',
                  style: const TextStyle(
                    color: Color(0xFF9EA3C7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: Color(0xFFFFDCA8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final letterId = reportData['letterId'] as String? ?? '';
    final commentId = reportData['commentId'] as String? ?? '';
    final targetOwnerUid = reportData['targetOwnerUid'] as String? ?? '';
    final status = reportData['status'] as String? ?? 'pending';
    final createdAt = reportData['createdAt'] as Timestamp?;

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
            title: typeText(targetType),
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
              _row('편지 ID', letterId.isEmpty ? '없음' : letterId),
              _row('댓글 ID', commentId.isEmpty ? '없음' : commentId),
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
              onPressed: () => showOriginalContent(context),
              icon: const Icon(Icons.article_outlined, size: 18),
              label: Text(originalButtonText(targetType)),
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
                await hideOriginalContent(context);
              },
              icon: const Icon(Icons.visibility_off_outlined, size: 18),
              label: Text(hideButtonText(targetType)),
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
