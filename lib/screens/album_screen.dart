import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cat_profile.dart';
import '../models/post.dart';
import '../services/cat_service.dart';
import '../services/post_service.dart';
import '../widgets/cat_post_card.dart' hide ThreeDotLoading;
import 'edit_post_screen.dart';
import '../widgets/post_detail_dialog.dart' hide ThreeDotLoading;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import '../services/block_service.dart';

import '../widgets/album/album_tabs.dart';

import '../widgets/album/cat_filter_area.dart';
import '../widgets/album/album_toolbar.dart';
import '../widgets/report/post_report_dialog.dart';
import '../widgets/common/three_dot_loading.dart';
import '../widgets/album/delete_posts_confirm_dialog.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AlbumScreen>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

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
    _loadingController.dispose();
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

        if (selectedCatProfileId != null &&
            !loadedCats.any((cat) => cat.id == selectedCatProfileId)) {
          selectedCatProfileId = null;
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

    final confirm = await showDeletePostsConfirmDialog(
      context: context,
      count: selectedPostIds.length,
    );

    if (!confirm) return;

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
                          builder: (_) =>
                              EditPostScreen(post: post, returnTarget: 'album'),
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

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFFFFF8F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            title: const Text(
                              '게시글 삭제',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5C4033),
                              ),
                            ),
                            content: const Text(
                              '게시글을 삭제할까요?\n삭제 후에는 되돌릴 수 없어요.',
                              style: TextStyle(
                                color: Color(0xFF5A372F),
                                height: 1.4,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text(
                                  '삭제',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != true) return;

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
                      showPostReportDialog(context: context, post: post);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_off_outlined),
                    title: const Text('사용자 차단'),
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);

                      await Future.delayed(const Duration(milliseconds: 150));

                      if (!mounted) return;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: const Color(0xFFFFF8F2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          title: const Text(
                            '사용자 차단',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5C4033),
                            ),
                          ),
                          content: Text(
                            '@${post.userId} 님을 차단할까요?\n\n'
                            '차단하면 이 사용자의 게시글이\n'
                            '더 이상 보이지 않아요.',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.55,
                              color: Color(0xFF5A372F),
                            ),
                          ),
                          actionsPadding: const EdgeInsets.only(
                            right: 20,
                            bottom: 12,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                  color: Color(0xFF8A756C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text(
                                '차단',
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
          return Center(child: ThreeDotLoading(controller: _loadingController));
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
                  Navigator.pop(context); // 상세창 닫기
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
                        child: ThreeDotLoading(controller: _loadingController),
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
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: ThreeDotLoading(controller: _loadingController),
            ),
          );
        }

        final post = posts[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: CatPostCard(
            imagePath: post.thumbnailUrl.isNotEmpty
                ? post.thumbnailUrl
                : post.imageUrl,

            originalImagePath: post.imageUrl,
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
      return Center(child: ThreeDotLoading(controller: _loadingController));
    }

    if (selectedAlbumTab == 1 && isLoadingScraps) {
      return Center(child: ThreeDotLoading(controller: _loadingController));
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
          AlbumTabs(
            selectedAlbumTab: selectedAlbumTab,
            onTabSelected: (index) async {
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
          ),
          const SizedBox(height: 14),
          if (selectedAlbumTab == 0)
            CatFilterArea(
              isLoadingCats: isLoadingCats,
              loadingController: _loadingController,
              catProfiles: catProfiles,
              selectedCatProfileId: selectedCatProfileId,
              onCatSelected: (catId) {
                setState(() {
                  selectedCatProfileId = catId;
                  isSelectionMode = false;
                  selectedPostIds.clear();
                });

                scrollAlbumToTop();
              },
            ),
          if (selectedAlbumTab == 0) const SizedBox(height: 6),
          AlbumToolbar(
            selectedSort: selectedSort,
            isGridView: isGridView,
            onSortSelected: (value) {
              setState(() {
                selectedSort = value;
                isSelectionMode = false;
                selectedPostIds.clear();
              });

              scrollAlbumToTop();
            },
            onViewChanged: (grid) {
              setState(() {
                isGridView = grid;

                if (!grid) {
                  isSelectionMode = false;
                  selectedPostIds.clear();
                }
              });
            },
          ),
          const SizedBox(height: 4),
          Expanded(child: buildAlbumContent(posts)),
        ],
      ),
    );
  }
}
