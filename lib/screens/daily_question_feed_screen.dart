import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/cat_post_card.dart';

class DailyQuestionFeedScreen extends StatefulWidget {
  final String dailyQuestionId;
  final String dailyQuestionText;

  const DailyQuestionFeedScreen({
    super.key,
    required this.dailyQuestionId,
    required this.dailyQuestionText,
  });

  @override
  State<DailyQuestionFeedScreen> createState() =>
      _DailyQuestionFeedScreenState();
}

class _DailyQuestionFeedScreenState extends State<DailyQuestionFeedScreen> {
  bool isLoading = true;
  bool isRandomOrder = false;

  List<Post> posts = [];
  List<Post> randomPosts = [];
  Set<String> scrappedPostIds = {};

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  Future<void> loadFeed() async {
    final loadedPosts = await PostService.loadPostsByDailyQuestionId(
      widget.dailyQuestionId,
    );
    final loadedScrapIds = await PostService.loadMyScrapIds();

    if (!mounted) return;

    final shuffledPosts = [...loadedPosts]..shuffle(Random());

    setState(() {
      posts = loadedPosts;
      randomPosts = shuffledPosts;
      scrappedPostIds = loadedScrapIds;
      isLoading = false;
    });
  }

  Future<void> toggleScrap(Post post) async {
    final isScrapped = scrappedPostIds.contains(post.id);

    await PostService.setScrap(post: post, isScrapped: !isScrapped);

    if (!mounted) return;

    setState(() {
      if (isScrapped) {
        scrappedPostIds.remove(post.id);
      } else {
        scrappedPostIds.add(post.id);
      }
    });
  }

  void updatePostCommentCount(String postId, int commentCount) {
    if (!mounted) return;

    setState(() {
      final index = posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final oldPost = posts[index];

        posts[index] = Post(
          id: oldPost.id,
          ownerUid: oldPost.ownerUid,
          userId: oldPost.userId,
          catProfileId: oldPost.catProfileId,
          catName: oldPost.catName,
          imageUrl: oldPost.imageUrl,
          thumbnailUrl: oldPost.thumbnailUrl,
          caption: oldPost.caption,
          tags: oldPost.tags,
          aspectRatio: oldPost.aspectRatio,
          createdAt: oldPost.createdAt,
          updatedAt: oldPost.updatedAt,
          isDeleted: oldPost.isDeleted,
          isHidden: oldPost.isHidden,
          reportCount: oldPost.reportCount,
          scrapCount: oldPost.scrapCount,
          commentCount: commentCount,
          unreadReviewCount: oldPost.unreadReviewCount,
          visibility: oldPost.visibility,
          storagePath: oldPost.storagePath,
          thumbnailStoragePath: oldPost.thumbnailStoragePath,
          catProfileImageUrl: oldPost.catProfileImageUrl,
          isVirtualCat: oldPost.isVirtualCat,
          dailyQuestionId: oldPost.dailyQuestionId,
          dailyQuestionText: oldPost.dailyQuestionText,
        );
      }

      final randomIndex = randomPosts.indexWhere((post) => post.id == postId);
      if (randomIndex != -1) {
        final oldPost = randomPosts[randomIndex];

        randomPosts[randomIndex] = Post(
          id: oldPost.id,
          ownerUid: oldPost.ownerUid,
          userId: oldPost.userId,
          catProfileId: oldPost.catProfileId,
          catName: oldPost.catName,
          imageUrl: oldPost.imageUrl,
          thumbnailUrl: oldPost.thumbnailUrl,
          caption: oldPost.caption,
          tags: oldPost.tags,
          aspectRatio: oldPost.aspectRatio,
          createdAt: oldPost.createdAt,
          updatedAt: oldPost.updatedAt,
          isDeleted: oldPost.isDeleted,
          isHidden: oldPost.isHidden,
          reportCount: oldPost.reportCount,
          scrapCount: oldPost.scrapCount,
          commentCount: commentCount,
          unreadReviewCount: oldPost.unreadReviewCount,
          visibility: oldPost.visibility,
          storagePath: oldPost.storagePath,
          thumbnailStoragePath: oldPost.thumbnailStoragePath,
          catProfileImageUrl: oldPost.catProfileImageUrl,
          isVirtualCat: oldPost.isVirtualCat,
          dailyQuestionId: oldPost.dailyQuestionId,
          dailyQuestionText: oldPost.dailyQuestionText,
        );
      }
    });
  }

  Widget _sortChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD9C9) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFF0D5CA)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF5C4033) : const Color(0xFFB08678),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _questionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D5CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🐾 오늘의 냥문답',
            style: TextStyle(
              color: Color(0xFF8A5A44),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.dailyQuestionText,
            style: const TextStyle(
              color: Color(0xFF3D241E),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyAnswerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '아직 올라온 답변이 없어요 🐾',
        style: TextStyle(
          color: Color(0xFF8A6A5A),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final displayPosts = isRandomOrder ? randomPosts : posts;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '오늘의 냥문답',
          style: TextStyle(
            color: Color(0xFF1F1A24),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD8CC)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 120),
              children: [
                _questionHeader(),

                const SizedBox(height: 22),

                Text(
                  posts.isEmpty ? '오늘의 답변' : '오늘의 답변 ${posts.length}개',
                  style: const TextStyle(
                    color: Color(0xFF3D241E),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                if (posts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _sortChip(
                        label: '최신순',
                        selected: !isRandomOrder,
                        onTap: () {
                          setState(() {
                            isRandomOrder = false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _sortChip(
                        label: '랜덤순',
                        selected: isRandomOrder,
                        onTap: () {
                          final shuffledPosts = [...posts]..shuffle(Random());

                          setState(() {
                            randomPosts = shuffledPosts;
                            isRandomOrder = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (isRandomOrder) ...[
                    const SizedBox(height: 9),
                    const Text(
                      '✨ 매번 새로운 답변을 만날 수 있어요.',
                      style: TextStyle(
                        color: Color(0xFFB08678),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 14),

                if (posts.isEmpty)
                  _emptyAnswerCard()
                else
                  ...displayPosts.map((post) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: CatPostCard(
                        imagePath: post.imageUrl,
                        originalImagePath: post.imageUrl,
                        caption: post.caption,
                        tagText: post.tags.map((tag) => '#$tag').join('   '),
                        scrapCount: post.scrapCount,
                        createdAt: post.createdAt ?? DateTime.now(),
                        catName: post.catName,
                        catProfileId: post.catProfileId,
                        userId: post.userId,
                        isScrapped: scrappedPostIds.contains(post.id),
                        showMoreButton: false,
                        onScrapTap: post.ownerUid == currentUid
                            ? null
                            : () {
                                toggleScrap(post);
                              },
                        catProfileImageUrl: post.catProfileImageUrl,
                        isVirtualCat: post.isVirtualCat,
                        commentCount: post.commentCount,
                        postId: post.id,
                        canWriteReview: post.ownerUid != currentUid,
                        dailyQuestionId: post.dailyQuestionId,
                        dailyQuestionText: post.dailyQuestionText,
                        onReviewChanged: (commentCount) {
                          updatePostCommentCount(post.id, commentCount);
                        },
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
