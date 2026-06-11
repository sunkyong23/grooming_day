import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminUserReportDetailScreen extends StatelessWidget {
  final String reportId;
  final Map<String, dynamic> reportData;

  const AdminUserReportDetailScreen({
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

  Future<void> updateUserReportStatus({required String status}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('userReports')
        .doc(reportId)
        .update({
          'status': status,
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': currentUser?.uid,
        });
  }

  Future<void> suspendTargetUser(BuildContext context) async {
    final targetUid = reportData['targetUid'] as String? ?? '';
    final targetUserId = reportData['targetUserId'] as String? ?? '';

    if (targetUid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('정지할 사용자 UID를 찾을 수 없어요.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('사용자 정지'),
          content: Text(
            targetUserId.isEmpty
                ? '이 사용자를 정지할까요?'
                : '@$targetUserId 사용자를 정지할까요?',
          ),
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
              child: const Text('정지'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('users').doc(targetUid).update({
      'isSuspended': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await updateUserReportStatus(status: 'resolved');

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('사용자를 정지하고 신고를 처리 완료했어요.')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final targetUid = reportData['targetUid'] as String? ?? '';
    final targetUserId = reportData['targetUserId'] as String? ?? '';
    final reporterUid = reportData['reporterUid'] as String? ?? '';
    final reporterUserId = reportData['reporterUserId'] as String? ?? '';
    final reason = reportData['reason'] as String? ?? '';
    final description = reportData['description'] as String? ?? '';
    final status = reportData['status'] as String? ?? 'pending';
    final createdAt = reportData['createdAt'] as Timestamp?;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text(
          '사용자 신고 상세',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoCard(
            title: '사용자 신고',
            children: [
              _row('상태', statusText(status)),
              _row('신고 대상', targetUserId.isEmpty ? '알 수 없음' : '@$targetUserId'),
              _row('대상 UID', targetUid.isEmpty ? '없음' : targetUid),
              _row('신고 사유', reason.isEmpty ? '없음' : reason),
              _row('상세 내용', description.isEmpty ? '없음' : description),
              _row(
                '신고자',
                reporterUserId.isEmpty ? '알 수 없음' : '@$reporterUserId',
              ),
              _row('신고자 UID', reporterUid.isEmpty ? '없음' : reporterUid),
              _row('신고일', formatDate(createdAt)),
            ],
          ),

          const SizedBox(height: 20),

          if (status == 'pending') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await suspendTargetUser(context);
                },
                icon: const Icon(Icons.person_off_outlined, size: 18),
                label: const Text('대상 사용자 정지'),
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

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await updateUserReportStatus(status: 'resolved');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('사용자 신고를 처리 완료했어요.')),
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
                      await updateUserReportStatus(status: 'rejected');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('사용자 신고를 반려했어요.')),
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
