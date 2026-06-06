import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/cat_post_card.dart';
import 'edit_post_screen.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Post> myPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyPosts();
  }

  Future<void> loadMyPosts() async {
    try {
      final loadedPosts = await PostService.loadMyPosts();

      if (!mounted) return;

      setState(() {
        myPosts = loadedPosts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('앨범을 불러오지 못했어요: $e')));
    }
  }

  Future<void> showPostMoreMenu(Post post) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF7F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('수정'),
                  textColor: const Color(0xFF5A372F),
                  iconColor: const Color(0xFF9A6B60),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPostScreen(post: post),
                      ),
                    );

                    if (result == 'album' || result == 'home') {
                      await loadMyPosts();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('삭제'),
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await PostService.deletePost(post);
                    await loadMyPosts();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                    );
                  },
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('나의 앨범'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myPosts.isEmpty
          ? const Center(child: Text('아직 앨범에 담긴 게시글이 없어요 🐾'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: myPosts.map((post) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: CatPostCard(
                    imagePath: post.imageUrl,
                    caption: post.caption,
                    scrapCount: post.scrapCount,
                    tagText: post.tags.map((tag) => '#$tag').join('   '),
                    createdAt: post.createdAt ?? DateTime.now(),
                    catName: post.catName,
                    catProfileImageUrl: post.catProfileImageUrl,
                    isVirtualCat: post.isVirtualCat,
                    commentCount: post.commentCount,
                    postId: post.id,
                    userId: post.userId,
                    isScrapped: false,
                    onScrapTap: () {},
                    showMoreButton: true,
                    onMoreTap: () {
                      showPostMoreMenu(post);
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }
}
