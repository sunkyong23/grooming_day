import 'package:flutter/material.dart';

import '../models/cat_profile.dart';
import '../models/post.dart';
import '../services/cat_service.dart';
import '../services/post_service.dart';
import '../widgets/cat_post_card.dart';
import 'edit_post_screen.dart';
import '../widgets/post_detail_dialog.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Post> myPosts = [];
  List<CatProfile> catProfiles = [];

  bool isLoading = true;
  bool isLoadingCats = true;

  String? selectedCatProfileId;
  String selectedSort = 'latest';

  int selectedAlbumTab = 0; // 0: 내 앨범, 1: 꾹꾹 앨범
  bool isGridView = true; // true: 그리드, false: 피드

  @override
  void initState() {
    super.initState();
    loadMyPosts();
    loadCatProfiles();
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

  Future<void> loadCatProfiles() async {
    try {
      final loadedCats = await CatService.loadMyCatProfiles();

      if (!mounted) return;

      setState(() {
        catProfiles = loadedCats;

        if (loadedCats.isNotEmpty && selectedCatProfileId == null) {
          selectedCatProfileId = loadedCats.first.id;
        }

        isLoadingCats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingCats = false;
      });
    }
  }

  List<Post> get filteredPosts {
    if (selectedAlbumTab == 1) {
      return [];
    }

    if (selectedCatProfileId == null) {
      return myPosts;
    }

    return myPosts
        .where((post) => post.catProfileId == selectedCatProfileId)
        .toList();
  }

  List<Post> get sortedPosts {
    final posts = [...filteredPosts];

    if (selectedSort == 'latest') {
      posts.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    } else if (selectedSort == 'oldest') {
      posts.sort(
        (a, b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );
    } else if (selectedSort == 'scrap') {
      posts.sort((a, b) => b.scrapCount.compareTo(a.scrapCount));
    } else if (selectedSort == 'review') {
      posts.sort((a, b) => b.commentCount.compareTo(a.commentCount));
    }

    return posts;
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

  Widget buildAlbumTab({required String label, required int index}) {
    final isSelected = selectedAlbumTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedAlbumTab = index;
          });
        },
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD7B8) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF6F3F2E)
                  : const Color(0xFFB08678),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAlbumTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEFE6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              buildAlbumTab(label: '내 앨범', index: 0),
              const SizedBox(width: 4),
              buildAlbumTab(label: '꾹꾹 앨범', index: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCatFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 7)
            : EdgeInsets.zero,
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFFFEFEA),
                borderRadius: BorderRadius.circular(999),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF6F3F2E)
                : const Color(0xFFC0A39A),
          ),
        ),
      ),
    );
  }

  Widget buildCatFilterArea() {
    if (isLoadingCats) {
      return const SizedBox(
        height: 38,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            buildCatFilterChip(
              label: '전체',
              isSelected: selectedCatProfileId == null,
              onTap: () {
                setState(() {
                  selectedCatProfileId = null;
                });
              },
            ),
            ...catProfiles.map((cat) {
              return buildCatFilterChip(
                label: cat.name,
                isSelected: selectedCatProfileId == cat.id,
                onTap: () {
                  setState(() {
                    selectedCatProfileId = cat.id;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String get selectedSortLabel {
    if (selectedSort == 'latest') return '최신순';
    if (selectedSort == 'oldest') return '오래된 순';
    if (selectedSort == 'scrap') return '스크랩 많은 순';
    if (selectedSort == 'review') return '감상평 많은 순';
    return '최신순';
  }

  Widget buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          buildSortButton(),

          const Spacer(),

          GestureDetector(
            onTap: () {
              setState(() {
                isGridView = true;
              });
            },
            child: Icon(
              Icons.grid_view_rounded,
              size: 22,
              color: isGridView
                  ? const Color(0xFF8A5A44)
                  : const Color(0xFFC9B8AF),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {
              setState(() {
                isGridView = false;
              });
            },
            child: Icon(
              Icons.view_agenda_outlined,
              size: 22,
              color: !isGridView
                  ? const Color(0xFF8A5A44)
                  : const Color(0xFFC9B8AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSortButton() {
    return GestureDetector(
      onTap: () {
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
                    buildSortOption(
                      label: '최신순',
                      value: 'latest',
                      bottomSheetContext: bottomSheetContext,
                    ),
                    buildSortOption(
                      label: '오래된 순',
                      value: 'oldest',
                      bottomSheetContext: bottomSheetContext,
                    ),
                    buildSortOption(
                      label: '스크랩 많은 순',
                      value: 'scrap',
                      bottomSheetContext: bottomSheetContext,
                    ),
                    buildSortOption(
                      label: '감상평 많은 순',
                      value: 'review',
                      bottomSheetContext: bottomSheetContext,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedSortLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9A6B60),
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Color(0xFF9A6B60),
          ),
        ],
      ),
    );
  }

  Widget buildSortOption({
    required String label,
    required String value,
    required BuildContext bottomSheetContext,
  }) {
    final isSelected = selectedSort == value;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? const Color(0xFF6F3F2E) : const Color(0xFF8A5A44),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: Color(0xFFFF8A7A))
          : null,
      onTap: () {
        setState(() {
          selectedSort = value;
        });

        Navigator.pop(bottomSheetContext);
      },
    );
  }

  Widget buildGridView(List<Post> posts) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => PostDetailDialog(
                imageUrl: post.imageUrl,
                catName: post.catName,
                caption: post.caption,
                postId: post.id,
                createdAt: post.createdAt ?? DateTime.now(),
                tagText: post.tags.map((tag) => '#$tag').join(' '),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  color: const Color(0xFFFFEFE6),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFFEFE6),
                  alignment: Alignment.center,
                  child: const Text('🐾', style: TextStyle(fontSize: 18)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildFeedView(List<Post> posts) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: posts.map((post) {
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
    );
  }

  Widget buildAlbumContent(List<Post> posts) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedAlbumTab == 1) {
      return const Center(
        child: Text(
          '꾹꾹 앨범은 곧 연결할게요 🐾',
          style: TextStyle(fontSize: 13, color: Color(0xFFB08678)),
        ),
      );
    }

    final visiblePosts = selectedCatProfileId == null
        ? posts
        : posts
              .where((post) => post.catProfileId == selectedCatProfileId)
              .toList();

    if (visiblePosts.isEmpty) {
      return const Center(
        child: Text(
          '아직 앨범에 담긴 게시글이 없어요 🐾',
          style: TextStyle(fontSize: 13, color: Color(0xFFB08678)),
        ),
      );
    }

    return isGridView
        ? buildGridView(visiblePosts)
        : buildFeedView(visiblePosts);
  }

  @override
  Widget build(BuildContext context) {
    final posts = sortedPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('나의 앨범'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          buildAlbumTabs(),

          const SizedBox(height: 14),

          buildCatFilterArea(),

          const SizedBox(height: 6),

          buildViewToggle(),

          const SizedBox(height: 4),

          Expanded(child: buildAlbumContent(posts)),
        ],
      ),
    );
  }
}
