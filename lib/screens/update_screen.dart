import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'update_detail_screen.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

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
        stream: FirebaseFirestore.instance
            .collection('updates')
            .where('isVisible', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final updates = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final data = updates[index].data() as Map<String, dynamic>;

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
              );
            },
          );
        },
      ),
    );
  }
}
