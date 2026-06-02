import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notice_detail_screen.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text('공지사항', style: TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .where('isVisible', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '등록된 공지사항이 없어요 🐾',
                style: TextStyle(color: Color(0xFFB08678)),
              ),
            );
          }

          final notices = snapshot.data!.docs;

          notices.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aPinned = aData['isPinned'] == true;
            final bPinned = bData['isPinned'] == true;

            if (aPinned != bPinned) {
              return aPinned ? -1 : 1;
            }

            final aCreatedAt = aData['createdAt'] as Timestamp?;
            final bCreatedAt = bData['createdAt'] as Timestamp?;

            if (aCreatedAt == null || bCreatedAt == null) return 0;

            return bCreatedAt.compareTo(aCreatedAt);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: notices.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 28, color: Color(0xFFE8DCD4)),
            itemBuilder: (context, index) {
              final notice = notices[index];
              final data = notice.data() as Map<String, dynamic>;

              final title = data['title'] ?? '제목 없음';
              final content = data['content'] ?? '';
              final isPinned = data['isPinned'] ?? false;
              final createdAt = data['createdAt'] as Timestamp?;
              final dateText = createdAt == null
                  ? ''
                  : '${createdAt.toDate().year}.${createdAt.toDate().month.toString().padLeft(2, '0')}.${createdAt.toDate().day.toString().padLeft(2, '0')}';

              return ListTile(
                contentPadding: EdgeInsets.zero,

                title: Text(
                  isPinned ? '📌 $title' : title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D241E),
                  ),
                ),

                subtitle: dateText.isEmpty
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB08678),
                          ),
                        ),
                      ),

                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB08678),
                ),

                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NoticeDetailScreen(title: title, content: content),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
