import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_report_detail_screen.dart';

class AdminReportListScreen extends StatelessWidget {
  const AdminReportListScreen({super.key});

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();

    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'resolved':
        return '처리완료';
      case 'rejected':
        return '반려';
      default:
        return '대기중';
    }
  }

  String typeText(String targetType) {
    switch (targetType) {
      case 'review':
        return '감상평 신고';
      case 'post':
        return '게시글 신고';
      default:
        return '기타 신고';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text(
          '게시글/감상평 신고',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '신고 목록을 불러오지 못했어요.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A756C),
                    height: 1.5,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(
              child: Text(
                '대기 중인 신고가 없어요 🐾',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB08678),
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = reports[index];
              final data = doc.data() as Map<String, dynamic>;

              final targetType = data['targetType'] as String? ?? '';
              final reason = data['reason'] as String? ?? '사유 없음';
              final reporterUserId =
                  data['reporterUserId'] as String? ?? '알 수 없음';
              final status = data['status'] as String? ?? 'pending';
              final createdAt = data['createdAt'] as Timestamp?;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminReportDetailScreen(
                        reportId: doc.id,
                        reportData: data,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB58A7B).withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: Color(0xFFFF8A7A)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeText(targetType),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF3D241E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '사유: $reason',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6F4A40),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '신고자: @$reporterUserId · ${formatDate(createdAt)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB08678),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFEA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusText(status),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF8A7A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
