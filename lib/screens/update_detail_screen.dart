import 'package:flutter/material.dart';

class UpdateDetailScreen extends StatelessWidget {
  final String version;
  final String title;
  final String content;

  const UpdateDetailScreen({
    super.key,
    required this.version,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: Text(version, style: const TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D241E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF5C4033),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
