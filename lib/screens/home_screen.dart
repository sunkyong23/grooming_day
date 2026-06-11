import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

import '../widgets/cat_post_card.dart';
import '../widgets/tag_chip.dart';
import '../widgets/header.dart';

import '../services/post_service.dart';
import '../services/report_service.dart';
import '../services/block_service.dart';
import '../services/user_report_service.dart';

Set<String> scrappedPostIds = {};

class HomeScreen extends StatefulWidget {
  final Function(Post, bool)? onPostCreatedFromHome;

  const HomeScreen({super.key, this.onPostCreatedFromHome});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<String> tags = const [
    '오늘의',
    '아깽이',
    '어르신',
    '장난꾸러기',
    '사랑스러운',
    '귀여워',
    '행복해',
    '일상',
    '평온한하루',
    '식빵굽기',
    '발라당',
    '심기불편',
    '사고뭉치',
    '정말못말려',
  ];

  String? selectedFeedTag = '오늘의';

  final List<Post> posts = [];
  final List<Post> myPosts = [];

  final ScrollController feedScrollController = ScrollController();

  DocumentSnapshot? _lastPostDocument;
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;

  static const int _postPageLimit = 20;

  void scrollFeedToTop() {
    if (!feedScrollController.hasClients) return;

    feedScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();

    loadInitialData();

    feedScrollController.addListener(() {
      if (!feedScrollController.hasClients) return;

      if (feedScrollController.position.pixels >=
          feedScrollController.position.maxScrollExtent - 400) {
        loadMorePostsFromFirestore();
      }
    });
  }

  @override
  void dispose() {
    feedScrollController.dispose();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    await loadPostsFromFirestore();
    await loadMyPostsFromFirestore();
    await loadMyScraps();
  }

  Future<void> refreshPostLists() async {
    await loadPostsFromFirestore();
    await loadMyPostsFromFirestore();
    await loadMyScraps();
  }

  Future<void> loadMyScraps() async {
    final loadedScrapIds = await PostService.loadMyScrapIds();

    if (!mounted) return;

    setState(() {
      scrappedPostIds = loadedScrapIds;
    });
  }

  void addPost(Post post) {
    if (post.tags.isNotEmpty) {
      setState(() {
        selectedFeedTag = null;
      });
    }

    refreshPostLists();
  }

  Future<void> loadPostsFromFirestore() async {
    if (_isLoadingPosts) return;

    if (mounted) {
      setState(() {
        _isLoadingPosts = true;
        _hasMorePosts = true;
        _lastPostDocument = null;
        posts.clear();
      });
    }

    try {
      final page = await PostService.loadPostsPage(
        tag: selectedFeedTag,
        limit: _postPageLimit,
      );
      final blockedUids = await BlockService.loadBlockedUserUids();

      final visiblePosts = page.posts
          .where((post) => !blockedUids.contains(post.ownerUid))
          .toList();
      if (!mounted) return;

      setState(() {
        posts.addAll(visiblePosts);
        _lastPostDocument = page.lastDocument;
        _hasMorePosts = page.hasMore;
        _isLoadingPosts = false;
      });
    } catch (e) {
      debugPrint('홈 피드 로딩 오류: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> loadPostsByTagFromFirestore(String tag) async {
    if (_isLoadingPosts) return;

    if (mounted) {
      setState(() {
        _isLoadingPosts = true;
        _hasMorePosts = true;
        _lastPostDocument = null;
        posts.clear();
      });
    }

    try {
      final page = await PostService.loadPostsPage(
        tag: tag,
        limit: _postPageLimit,
      );

      final blockedUids = await BlockService.loadBlockedUserUids();

      final visiblePosts = page.posts
          .where((post) => !blockedUids.contains(post.ownerUid))
          .toList();

      if (!mounted) return;

      setState(() {
        posts.addAll(visiblePosts);
        _lastPostDocument = page.lastDocument;
        _hasMorePosts = page.hasMore;
        _isLoadingPosts = false;
      });
    } catch (e) {
      debugPrint('태그 피드 로딩 오류: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> loadMorePostsFromFirestore() async {
    if (_isLoadingPosts || !_hasMorePosts || _lastPostDocument == null) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final page = await PostService.loadPostsPage(
        tag: selectedFeedTag,
        lastDocument: _lastPostDocument,
        limit: _postPageLimit,
      );

      final blockedUids = await BlockService.loadBlockedUserUids();

      final visiblePosts = page.posts
          .where((post) => !blockedUids.contains(post.ownerUid))
          .toList();

      if (!mounted) return;

      setState(() {
        posts.addAll(visiblePosts);
        _lastPostDocument = page.lastDocument;
        _hasMorePosts = page.hasMore;
        _isLoadingPosts = false;
      });
    } catch (e) {
      debugPrint('추가 피드 로딩 오류: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> loadMyPostsFromFirestore() async {
    final loadedMyPosts = await PostService.loadMyPosts();

    if (!mounted) return;

    setState(() {
      myPosts.clear();
      myPosts.addAll(loadedMyPosts);
    });
  }

  Future<void> handleTagTap(String tag) async {
    if (!mounted) return;

    setState(() {
      if (tag == '오늘의') {
        selectedFeedTag = '오늘의';
      } else if (selectedFeedTag == tag) {
        selectedFeedTag = null;
      } else {
        selectedFeedTag = tag;
      }
    });

    try {
      if (tag == '오늘의' || selectedFeedTag == null) {
        await loadPostsFromFirestore();
      } else {
        await loadPostsByTagFromFirestore(tag);
      }

      scrollFeedToTop();
    } catch (e) {
      debugPrint('태그 피드 로딩 오류: $e');
    }
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

                      if (result == 'album') {
                        await refreshPostLists();
                      } else if (result == 'home') {
                        setState(() {
                          selectedFeedTag = null;
                        });

                        await refreshPostLists();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('삭제'),
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      showDeletePostDialog(post);
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
                    leading: const Icon(Icons.person_outline),
                    title: const Text('사용자 신고'),
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      showUserReportDialog(post);
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
                        posts.removeWhere(
                          (item) => item.ownerUid == post.ownerUid,
                        );
                        myPosts.removeWhere(
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

  Future<void> showUserReportDialog(Post post) async {
    String selectedReason = '불쾌한 사용자';
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('사용자 신고'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(labelText: '신고 사유'),
                    items: const [
                      DropdownMenuItem(
                        value: '불쾌한 사용자',
                        child: Text('불쾌한 사용자'),
                      ),
                      DropdownMenuItem(value: '스팸/홍보', child: Text('스팸/홍보')),
                      DropdownMenuItem(value: '비방/욕설', child: Text('비방/욕설')),
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
                    decoration: const InputDecoration(labelText: '상세 내용'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
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
      await UserReportService.reportUser(
        reporterUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
        targetUid: post.ownerUid,
        targetUserId: post.userId,
        reason: selectedReason,
        detail: descriptionController.text,
      );

      descriptionController.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사용자 신고가 접수되었습니다.')));
    } catch (e) {
      descriptionController.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고 접수 중 오류가 발생했습니다.')));
    }
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
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
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
        targetOwnerUid: post.ownerUid,
        reason: selectedReason,
        description: descriptionController.text,
      );

      descriptionController.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다. 확인 후 조치할게요.')));
    } catch (e) {
      debugPrint('게시글 신고 오류: $e');

      descriptionController.dispose();

      if (!mounted) return;

      final message = e.toString().contains('이미 신고한 항목')
          ? '이미 신고한 항목이에요.'
          : '신고 접수 중 오류가 발생했어요. 잠시 후 다시 시도해주세요.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> showDeletePostDialog(Post post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('이 게시글을 삭제할까요? 삭제 후에는 되돌릴 수 없어요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await PostService.deletePost(post);

      await refreshPostLists();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글 삭제 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> openCameraAndCreatePost() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;
    if (!mounted) return;

    final CropAspectRatio? selectedRatio =
        await showModalBottomSheet<CropAspectRatio>(
          context: context,
          backgroundColor: const Color(0xFFFFF7F1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (bottomSheetContext) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '사진 비율 선택',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  ListTile(
                    leading: const Icon(Icons.crop_landscape),
                    title: const Text('가로 4:3'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 4, ratioY: 3),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.crop_portrait),
                    title: const Text('세로 4:5'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 4, ratioY: 5),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.crop_square),
                    title: const Text('정사각형 1:1'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 1, ratioY: 1),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );

    if (selectedRatio == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: selectedRatio,
    );

    if (croppedFile == null) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          onPostCreated: (post, isAlbumOnlyPost) {
            widget.onPostCreatedFromHome?.call(post, isAlbumOnlyPost);
          },
          initialImage: File(croppedFile.path),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = selectedFeedTag == '오늘의'
        ? ([...posts]..sort((a, b) => b.scrapCount.compareTo(a.scrapCount)))
        : [...posts];

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(onCameraTap: openCameraAndCreatePost),
                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFF0E3DC),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: tags.map((tag) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    await handleTagTap(tag);
                                  },
                                  child: TagChip(
                                    key: ValueKey(tag),
                                    text: tag,
                                    isSelected: selectedFeedTag == tag,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFFFFF7F1),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            builder: (bottomSheetContext) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  20,
                                  22,
                                  30,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '태그 전체보기',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF3D241E),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2.5,
                                      children: tags.map((tag) {
                                        return GestureDetector(
                                          onTap: () async {
                                            await handleTagTap(tag);

                                            if (bottomSheetContext.mounted) {
                                              Navigator.pop(bottomSheetContext);
                                            }
                                          },
                                          child: TagChip(
                                            key: ValueKey('sheet_$tag'),
                                            text: tag,
                                            isSelected: selectedFeedTag == tag,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            size: 20,
                            color: Color(0xFF8A756C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: feedScrollController,
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
                itemCount: filteredPosts.length + 1 + (_hasMorePosts ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const SizedBox(height: 24);
                  }

                  final postIndex = index - 1;

                  if (postIndex >= filteredPosts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final post = filteredPosts[postIndex];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: CatPostCard(
                      imagePath: post.imageUrl,
                      caption: post.caption,
                      catProfileImageUrl: post.catProfileImageUrl,
                      isVirtualCat: post.isVirtualCat,
                      scrapCount: post.scrapCount,
                      tagText: post.tags.map((tag) => '#$tag').join('   '),
                      createdAt: post.createdAt ?? DateTime.now(),
                      catName: post.catName,
                      userId: post.userId,
                      commentCount: post.commentCount,
                      postId: post.id,
                      canWriteReview: post.ownerUid != currentUid,
                      isScrapped: scrappedPostIds.contains(post.id),
                      onScrapTap: post.ownerUid == currentUid
                          ? null
                          : () {
                              toggleScrap(post);
                            },
                      showMoreButton: true,
                      onMoreTap: () {
                        showPostMoreMenu(post);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
