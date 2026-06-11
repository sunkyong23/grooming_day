import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'update_detail_screen.dart';

import '../services/update_service.dart';
import '../services/notification_service.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  Future<void> sendUpdateNotification({
    required BuildContext context,
    required String updateId,
    required String version,
    required String title,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('업데이트 알림 보내기'),
          content: Text('"$version · $title"\n\n전체 사용자에게 이 업데이트 알림을 보낼까요?'),
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
              child: const Text('보내기'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await NotificationService().createUpdateNotifications(
      updateId: updateId,
      updateTitle: title,
      version: version,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('업데이트 알림을 보냈어요.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text(
          '업데이트 내역',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: UpdateService.updates(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final updates = snapshot.data!.docs;

          if (updates.isEmpty) {
            return const Center(
              child: Text(
                '등록된 업데이트 내역이 없어요 🐾',
                style: TextStyle(color: Color(0xFFB08678)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: updates.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 28, color: Color(0xFFE8DCD4)),
            itemBuilder: (context, index) {
              final update = updates[index];
              final data = update.data() as Map<String, dynamic>;

              final version = data['version'] ?? '';
              final title = data['title'] ?? '';
              final content = data['content'] ?? '';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '🚀 $version',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D241E),
                  ),
                ),
                subtitle: Text(title),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UpdateDetailScreen(
                        version: version,
                        title: title,
                        content: content,
                      ),
                    ),
                  );
                },
                onLongPress: () async {
                  await sendUpdateNotification(
                    context: context,
                    updateId: update.id,
                    version: version,
                    title: title,
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
