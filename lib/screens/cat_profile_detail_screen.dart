import 'package:flutter/material.dart';

import '../models/cat_profile.dart';

import '../services/cat_service.dart';

import '../models/post.dart';
import '../services/post_service.dart';

class CatProfileDetailScreen extends StatefulWidget {
  final CatProfile cat;

  const CatProfileDetailScreen({super.key, required this.cat});

  @override
  State<CatProfileDetailScreen> createState() => _CatProfileDetailScreenState();
}

class _CatProfileDetailScreenState extends State<CatProfileDetailScreen> {
  List<Post> catPosts = [];

  @override
  void initState() {
    super.initState();
    loadCatPosts();
  }

  Future<void> loadCatPosts() async {
    print('고양이 ID = ${widget.cat.id}');
    print('고양이 이름 = ${widget.cat.name}');

    final posts = await PostService.loadPostsByCatProfile(widget.cat.id);

    print('불러온 게시글 수 = ${posts.length}');

    if (!mounted) return;

    setState(() {
      catPosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: Text(widget.cat.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('고양이 프로필 숨기기'),
                    content: const Text('이 고양이 프로필을 숨길까요?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('숨기기'),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) return;

              await CatService.hideCatProfile(widget.cat.id);

              if (!context.mounted) return;

              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: widget.cat.profileImageUrl.isNotEmpty
                    ? NetworkImage(widget.cat.profileImageUrl)
                    : null,
                child: widget.cat.profileImageUrl.isEmpty
                    ? const Icon(Icons.pets, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                widget.cat.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _infoTile('품종', widget.cat.breed),
            _infoTile('성별', widget.cat.gender),

            if (widget.cat.introduction.isNotEmpty)
              _infoTile('소개', widget.cat.introduction),

            const SizedBox(height: 30),

            const Text(
              '앨범',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 12),

            catPosts.isEmpty
                ? Container(
                    height: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('게시글이 없습니다 🐾'),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catPosts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemBuilder: (context, index) {
                      final post = catPosts[index];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(post.imageUrl, fit: BoxFit.cover),
                      );
                    },
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
