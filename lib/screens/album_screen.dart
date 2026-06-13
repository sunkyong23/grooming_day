import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cat_profile.dart';
import '../models/post.dart';
import '../services/cat_service.dart';
import '../services/post_service.dart';
import '../widgets/cat_post_card.dart';
import 'edit_post_screen.dart';
import '../widgets/post_detail_dialog.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import '../services/report_service.dart';
import '../services/block_service.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AlbumScreen> {
  List<Post> myPosts = [];
  List<CatProfile> catProfiles = [];

  bool isLoading = true;
  bool isLoadingCats = true;

  String? selectedCatProfileId;
  String selectedSort = 'latest';

  int selectedAlbumTab = 0;
  bool isGridView = true;

  bool isSelectionMode = false;
  final Set<String> selectedPostIds = {};

  List<Post> scrappedPosts = [];
  bool isLoadingScraps = false;
  bool hasLoadedScraps = false;

  final ScrollController albumScrollController = ScrollController();

  DocumentSnapshot? lastMyPostDocument;
  bool isLoadingMoreMyPosts = false;
  bool hasMoreMyPosts = true;

  static const int albumPageLimit = 20;

  @override
  void initState() {
    super.initState();

    loadMyPosts();
    loadCatProfiles();

    albumScrollController.addListener(() {
      if (!albumScrollController.hasClients) return;
      if (selectedAlbumTab != 0) return;

      if (albumScrollController.position.pixels >=
          albumScrollController.position.maxScrollExtent - 300) {
        loadMoreMyPosts();
      }
    });
  }

  @override
  void dispose() {
    albumScrollController.dispose();
    super.dispose();
  }

  Future<void> loadMyPosts() async {
    try {
      setState(() {
        isLoading = true;
        myPosts.clear();
        selectedPostIds.clear();
        isSelectionMode = false;
        lastMyPostDocument = null;
        hasMoreMyPosts = true;
      });

      final page = await PostService.loadMyPostsPage(limit: albumPageLimit);

      if (!mounted) return;

      setState(() {
        myPosts = page.posts;
        lastMyPostDocument = page.lastDocument;
        hasMoreMyPosts = page.hasMore;
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

  Future<void> loadMoreMyPosts() async {
    if (isLoadingMoreMyPosts || !hasMoreMyPosts || lastMyPostDocument == null) {
      return;
    }

    setState(() {
      isLoadingMoreMyPosts = true;
    });

    try {
      final page = await PostService.loadMyPostsPage(
        lastDocument: lastMyPostDocument,
        limit: albumPageLimit,
      );

      if (!mounted) return;

      setState(() {
        myPosts.addAll(page.posts);
        lastMyPostDocument = page.lastDocument;
        hasMoreMyPosts = page.hasMore;
        isLoadingMoreMyPosts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingMoreMyPosts = false;
      });

      debugPrint('앨범 추가 로딩 오류: $e');
    }
  }

  Future<void> loadMyScrappedPosts() async {
    setState(() {
      isLoadingScraps = true;
    });

    final blockedUids = await BlockService.loadBlockedUserUids();
    final loadedPosts = await PostService.loadMyScrappedPosts();

    if (!mounted) return;

    setState(() {
      scrappedPosts = loadedPosts
          .where((post) => !blockedUids.contains(post.ownerUid))
          .toList();
      isLoadingScraps = false;
      hasLoadedScraps = true;
    });
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

  void scrollAlbumToTop() {
    if (!albumScrollController.hasClients) return;

    albumScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void toggleSelection(String postId) {
    setState(() {
      if (selectedPostIds.contains(postId)) {
        selectedPostIds.remove(postId);
      } else {
        selectedPostIds.add(postId);
      }
    });
  }

  Future<void> deleteSelectedPosts() async {
    if (selectedPostIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          '게시글 삭제',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5C4033),
          ),
        ),
        content: Text(
          '${selectedPostIds.length}개의 게시글을 삭제할까요?\n'
          '삭제 후에는 되돌릴 수 없어요.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.45,
            color: Color(0xFF5A372F),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF8A756C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              '삭제',
              style: TextStyle(
                color: Color(0xFFFF7A7A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final postsToDelete = myPosts
        .where((post) => selectedPostIds.contains(post.id))
        .toList();

    try {
      for (final post in postsToDelete) {
        await PostService.deletePost(post);
      }

      await loadMyPosts();

      if (!mounted) return;

      setState(() {
        isSelectionMode = false;
        selectedPostIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${postsToDelete.length}개의 게시글을 삭제했어요.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 삭제 중 오류가 발생했어요: $e')));
    }
  }

  List<Post> get filteredPosts {
    if (selectedAlbumTab == 1) {
      return scrappedPosts;
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
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMyPost = post.ownerUid == currentUid;

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
                if (isMyPost) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('수정'),
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
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: const Text('게시글 신고'),
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      showReportDialog(post);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_off_outlined),
                    title: const Text('사용자 차단'),
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('사용자 차단'),
                          content: Text(
                            '@${post.userId} 사용자를 차단할까요?\n\n'
                            '차단하면 해당 사용자의 게시글이 보이지 않게 됩니다.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                '차단',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      await BlockService.blockUser(
                        blockedUid: post.ownerUid,
                        blockedUserId: post.userId,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('@${post.userId} 사용자를 차단했습니다.')),
                      );

                      setState(() {
                        myPosts.removeWhere(
                          (item) => item.ownerUid == post.ownerUid,
                        );

                        scrappedPosts.removeWhere(
                          (item) => item.ownerUid == post.ownerUid,
                        );
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showReportDialog(Post post) async {
    String selectedReason = '부적절한 사진';
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('게시글 신고'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(labelText: '신고 사유'),
                    items: const [
                      DropdownMenuItem(
                        value: '부적절한 사진',
                        child: Text('부적절한 사진'),
                      ),
                      DropdownMenuItem(value: '불쾌한 내용', child: Text('불쾌한 내용')),
                      DropdownMenuItem(value: '스팸/홍보', child: Text('스팸/홍보')),
                      DropdownMenuItem(
                        value: '개인정보 노출',
                        child: Text('개인정보 노출'),
                      ),
                      DropdownMenuItem(value: '기타', child: Text('기타')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: '상세 내용',
                      hintText: '필요하면 신고 내용을 적어주세요.',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    '신고',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      descriptionController.dispose();
      return;
    }

    try {
      await ReportService.createReport(
        targetType: 'post',
        targetId: post.id,
        postId: post.id,
        targetOwnerUid: post.ownerUid,
        reason: selectedReason,
        description: descriptionController.text,
      );

      descriptionController.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
    } catch (e) {
      descriptionController.dispose();

      if (!mounted) return;

      final message = e.toString().contains('이미 신고한 항목')
          ? '이미 신고한 게시글이에요.'
          : '신고 접수 중 오류가 발생했어요.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget buildAlbumTab({required String label, required int index}) {
    final isSelected = selectedAlbumTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedAlbumTab = index;
            isSelectionMode = false;
            selectedPostIds.clear();
          });

          scrollAlbumToTop();

          if (index == 1) {
            await loadMyScrappedPosts();
          }
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFBE5D8) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF3D241E)
                  : const Color(0xFF3D241E),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAlbumTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            buildAlbumTab(label: '내 앨범', index: 0),
            buildAlbumTab(label: '꾹꾹 앨범', index: 1),
          ],
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
            fontSize: 18,
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
        height: 34,
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
              onTap: () async {
                setState(() {
                  selectedCatProfileId = null;
                  isSelectionMode = false;
                  selectedPostIds.clear();
                });
                scrollAlbumToTop();
              },
            ),
            ...catProfiles.map((cat) {
              return buildCatFilterChip(
                label: cat.name,
                isSelected: selectedCatProfileId == cat.id,
                onTap: () async {
                  setState(() {
                    selectedCatProfileId = cat.id;
                    isSelectionMode = false;
                    selectedPostIds.clear();
                  });
                  scrollAlbumToTop();
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
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      child: Row(
        children: [
          buildSortButton(),
          const Spacer(),
          GestureDetector(
            onTap: () async {
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
            onTap: () async {
              setState(() {
                isGridView = false;
                isSelectionMode = false;
                selectedPostIds.clear();
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
      onTap: () async {
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
      onTap: () async {
        setState(() {
          selectedSort = value;
          isSelectionMode = false;
          selectedPostIds.clear();
        });

        Navigator.pop(bottomSheetContext);
        scrollAlbumToTop();
      },
    );
  }

  Widget buildGridView(List<Post> posts) {
    final shouldShowLoadingFooter =
        selectedAlbumTab == 0 && hasMoreMyPosts && selectedCatProfileId == null;

    return GridView.builder(
      controller: albumScrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: posts.length + (shouldShowLoadingFooter ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index >= posts.length) {
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final post = posts[index];

        return GestureDetector(
          onTap: () async {
            if (isSelectionMode) {
              toggleSelection(post.id);
              return;
            }

            if (selectedAlbumTab == 0 && post.unreadReviewCount > 0) {
              await PostService.clearUnreadReviewCount(post.id);

              if (mounted) {
                setState(() {
                  final targetIndex = myPosts.indexWhere(
                    (item) => item.id == post.id,
                  );

                  if (targetIndex != -1) {
                    final oldPost = myPosts[targetIndex];

                    myPosts[targetIndex] = Post(
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
                      commentCount: oldPost.commentCount,
                      visibility: oldPost.visibility,
                      storagePath: oldPost.storagePath,
                      thumbnailStoragePath: oldPost.thumbnailStoragePath,
                      catProfileImageUrl: oldPost.catProfileImageUrl,
                      isVirtualCat: oldPost.isVirtualCat,
                      unreadReviewCount: 0,
                    );
                  }
                });
              }
            }

            if (!context.mounted) return;

            showDialog(
              context: context,
              builder: (_) => PostDetailDialog(
                imageUrl: post.imageUrl,
                catName: post.catName,
                caption: post.caption,
                postId: post.id,
                createdAt: post.createdAt ?? DateTime.now(),
                tagText: post.tags.map((tag) => '#$tag').join(' '),
                canWriteReview:
                    post.ownerUid != FirebaseAuth.instance.currentUser?.uid,
                showMoreButton: true,
                onMoreTap: () {
                  Navigator.pop(context);
                  showPostMoreMenu(post);
                },
                showScrapButton: selectedAlbumTab == 1,
                isScrapped: selectedAlbumTab == 1,
                onScrapTap: selectedAlbumTab == 1
                    ? () async {
                        await PostService.setScrap(
                          post: post,
                          isScrapped: false,
                        );

                        scrappedPostIds.remove(post.id);

                        if (!mounted) return;

                        setState(() {
                          scrappedPosts.removeWhere(
                            (item) => item.id == post.id,
                          );
                        });

                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    : null,
              ),
            );
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: post.thumbnailUrl.isNotEmpty
                        ? post.thumbnailUrl
                        : post.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
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
                    errorWidget: (context, url, error) {
                      return Container(
                        color: const Color(0xFFFFEFE6),
                        alignment: Alignment.center,
                        child: const Text('🐾', style: TextStyle(fontSize: 18)),
                      );
                    },
                  ),
                ),
              ),

              if (selectedAlbumTab == 0 &&
                  post.unreadReviewCount > 0 &&
                  post.commentCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7F7F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              if (isSelectionMode)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Icon(
                    selectedPostIds.contains(post.id)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selectedPostIds.contains(post.id)
                        ? const Color(0xFFFF8A7A)
                        : Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFeedView(List<Post> posts) {
    final shouldShowLoadingFooter =
        selectedAlbumTab == 0 && hasMoreMyPosts && selectedCatProfileId == null;

    return ListView.builder(
      controller: albumScrollController,
      padding: const EdgeInsets.all(20),
      itemCount: posts.length + (shouldShowLoadingFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final post = posts[index];

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
            canWriteReview:
                post.ownerUid != FirebaseAuth.instance.currentUser?.uid,
            isScrapped: selectedAlbumTab == 1,
            onScrapTap: selectedAlbumTab == 1
                ? () async {
                    await PostService.setScrap(post: post, isScrapped: false);

                    scrappedPostIds.remove(post.id);

                    if (!mounted) return;

                    setState(() {
                      scrappedPosts.removeWhere((item) => item.id == post.id);
                    });
                  }
                : null,
            showMoreButton: true,
            onMoreTap: () {
              showPostMoreMenu(post);
            },
          ),
        );
      },
    );
  }

  Widget buildAlbumContent(List<Post> posts) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedAlbumTab == 1 && isLoadingScraps) {
      return const Center(child: CircularProgressIndicator());
    }

    final visiblePosts = selectedAlbumTab == 1
        ? posts
        : selectedCatProfileId == null
        ? posts
        : posts
              .where((post) => post.catProfileId == selectedCatProfileId)
              .toList();

    if (visiblePosts.isEmpty) {
      final emptyText = selectedAlbumTab == 0
          ? '아직 앨범에 담긴 게시글이 없어요 🐾'
          : '아직 꾹꾹한 게시글이 없어요 🐾';

      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(fontSize: 13, color: Color(0xFFB08678)),
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
        title: isSelectionMode
            ? Text(
                '${selectedPostIds.length}개 선택',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C4033),
                ),
              )
            : const Text(
                '나의 앨범',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D241E),
                ),
              ),
        actions: [
          if (selectedAlbumTab == 0 && isGridView)
            isSelectionMode
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSelectionMode = false;
                            selectedPostIds.clear();
                          });
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFF8A756C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: selectedPostIds.isEmpty
                            ? null
                            : deleteSelectedPosts,
                        child: const Text(
                          '삭제',
                          style: TextStyle(
                            color: Color(0xFFFF7A7A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : TextButton(
                    onPressed: () {
                      setState(() {
                        isSelectionMode = true;
                        selectedPostIds.clear();
                      });
                    },
                    child: const Text(
                      '선택',
                      style: TextStyle(
                        color: Color(0xFF8A5A44),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          buildAlbumTabs(),
          const SizedBox(height: 14),
          if (selectedAlbumTab == 0) buildCatFilterArea(),
          if (selectedAlbumTab == 0) const SizedBox(height: 6),
          buildViewToggle(),
          const SizedBox(height: 4),
          Expanded(child: buildAlbumContent(posts)),
        ],
      ),
    );
  }
}
