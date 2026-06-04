import 'package:flutter/material.dart';

import '../models/cat_profile.dart';

class CatProfileDetailScreen extends StatelessWidget {
  final CatProfile cat;

  const CatProfileDetailScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: Text(cat.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: cat.profileImageUrl.isNotEmpty
                    ? NetworkImage(cat.profileImageUrl)
                    : null,
                child: cat.profileImageUrl.isEmpty
                    ? const Icon(Icons.pets, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                cat.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _infoTile('품종', cat.breed),
            _infoTile('성별', cat.gender),

            if (cat.introduction.isNotEmpty) _infoTile('소개', cat.introduction),

            const SizedBox(height: 30),

            const Text(
              '앨범',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 12),

            Container(
              height: 160,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text('해당 고양이 게시글이 표시될 예정 🐾'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              '$title : ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}
