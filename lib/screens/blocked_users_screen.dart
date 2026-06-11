import 'package:flutter/material.dart';

import '../services/block_service.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        title: const Text(
          '차단한 사용자',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: StreamBuilder(
        stream: BlockService.blockedUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                '차단한 사용자가 없어요 🐾',
                style: TextStyle(fontSize: 13, color: Color(0xFFB08678)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final blockedUid =
                  data['blockedUid'] as String? ?? docs[index].id;
              final blockedUserId = data['blockedUserId'] as String? ?? '';

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      color: Color(0xFF9A6B60),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '@$blockedUserId',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5C4033),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await BlockService.unblockUser(blockedUid);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('@$blockedUserId 차단을 해제했어요.')),
                        );
                      },
                      child: const Text(
                        '해제',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
