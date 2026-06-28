import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

import '../services/post_service.dart';
import '../services/block_service.dart';

import '../widgets/post/delete_post_dialog.dart';
import '../widgets/report/post_report_dialog.dart';
import '../widgets/report/user_report_dialog.dart';
import '../widgets/report/block_user_confirm_dialog.dart';

import '../widgets/post/post_more_menu.dart' as post_menu;

import '../widgets/post/crop_ratio_bottom_sheet.dart';
import '../widgets/home/home_feed_list.dart';

import '../widgets/home/home_tag_header.dart';
import '../services/community_bgm_service.dart';

import '../models/daily_question.dart';
import '../services/daily_question_service.dart';

import '../widgets/daily_question_card_v2.dart';

import 'daily_question_feed_screen.dart';

Set<String> scrappedPostIds = {};

class HomeScreen extends StatefulWidget {
  final Function(Post, bool)? onPostCreatedFromHome;

  const HomeScreen({super.key, this.onPostCreatedFromHome});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int todayQuestionAnswerCount = 0;
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
  final Map<String, int> commentCountOverrides = {};

  final ScrollController feedScrollController = ScrollController();
  final ScrollController tagScrollController = ScrollController();

  bool _communityBgmEnabled = false;

  DocumentSnapshot? _lastPostDocument;
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;

  DailyQuestion? todayQuestion;
  bool isLoadingDailyQuestion = true;
  bool isDailyQuestionAnswered = false;

  static const int _postPageLimit = 20;

  late final AnimationController _loadingController;

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

    loadTodayQuestion();
    _initializeCommunityBgm();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

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
    CommunityBgmService.stop();

    _loadingController.dispose();
    feedScrollController.dispose();
    tagScrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeCommunityBgm() async {
    final enabled = await CommunityBgmService.isEnabled();

    if (!mounted) return;

    setState(() {
      _communityBgmEnabled = enabled;
    });

    if (enabled) {
      await CommunityBgmService.play();
    }
  }

  Future<void> _toggleCommunityBgm() async {
    final nextEnabled = !_communityBgmEnabled;

    setState(() {
      _communityBgmEnabled = nextEnabled;
    });

    await CommunityBgmService.saveSetting(nextEnabled);

    if (nextEnabled) {
      await CommunityBgmService.play();
    } else {
      await CommunityBgmService.stop();
    }
  }

  Future<void> loadTodayQuestion() async {
    final answered = await DailyQuestionService.instance.isTodayAnswered();
    final dismissed = await DailyQuestionService.instance.isTodayDismissed();
    final question = await DailyQuestionService.instance.getTodayQuestion();

    int answerCount = 0;

    if (question != null) {
      answerCount = await PostService.countPostsByDailyQuestionId(question.id);
    }

    if (!mounted) return;

    setState(() {
      isDailyQuestionAnswered = answered;
      todayQuestion = dismissed ? null : question;
      todayQuestionAnswerCount = answerCount;
      isLoadingDailyQuestion = false;
    });
  }

  void openTodayQuestionFeed() {
    final question = todayQuestion;

    if (question == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyQuestionFeedScreen(
          dailyQuestionId: question.id,
          dailyQuestionText: question.question,
        ),
      ),
    );
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

  void scrollToSelectedTag(String tag) {
    final index = tags.indexOf(tag);

    if (index == -1 || !tagScrollController.hasClients) return;

    const estimatedChipWidth = 90.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (index * estimatedChipWidth) -
        (screenWidth / 2) +
        (estimatedChipWidth / 2);

    final clampedOffset = targetOffset.clamp(
      0.0,
      tagScrollController.position.maxScrollExtent,
    );

    tagScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
      scrollToSelectedTag(tag);
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

  void updatePostCommentCount(String postId, int commentCount) {
    if (!mounted) return;

    setState(() {
      commentCountOverrides[postId] = commentCount;
    });
  }

  Future<void> showPostMoreMenu(Post post) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMyPost = post.ownerUid == currentUid;

    await post_menu.showPostMoreMenu(
      context: context,
      post: post,
      isMyPost: isMyPost,
      onEditTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditPostScreen(post: post)),
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
      onDeleteTap: () {
        showDeletePostDialog(post);
      },
      onReportTap: () {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          showPostReportDialog(context: context, post: post);
        });
      },
      onUserReportTap: () {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          showUserReportDialog(context: context, post: post);
        });
      },
      onBlockTap: () async {
        await Future.delayed(const Duration(milliseconds: 150));

        if (!mounted) return;

        final confirm = await showBlockUserConfirmDialog(
          context: context,
          userId: post.userId,
        );

        if (!confirm) return;

        await BlockService.blockUser(
          blockedUid: post.ownerUid,
          blockedUserId: post.userId,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('@${post.userId} 사용자를 차단했습니다.')));

        setState(() {
          posts.removeWhere((item) => item.ownerUid == post.ownerUid);
          myPosts.removeWhere((item) => item.ownerUid == post.ownerUid);
        });
      },
    );
  }

  Future<void> showDeletePostDialog(Post post) async {
    final shouldDelete = await showDeletePostConfirmDialog(context: context);

    if (!shouldDelete) return;

    try {
      await PostService.deletePost(post);

      await refreshPostLists();
      await loadTodayQuestion();

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

    final selectedRatio = await showCropRatioBottomSheet(context: context);

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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Column(
          children: [
            HomeTagHeader(
              tags: tags,
              selectedFeedTag: selectedFeedTag,
              tagScrollController: tagScrollController,
              onCameraTap: openCameraAndCreatePost,
              onTagTap: handleTagTap,
              communityBgmEnabled: _communityBgmEnabled,
              onCommunityBgmTap: _toggleCommunityBgm,
            ),

            if (todayQuestion != null)
              DailyQuestionCardV2(
                question: todayQuestion!,
                answered: isDailyQuestionAnswered,
                answerCount: todayQuestionAnswerCount,
                onTapFeed: openTodayQuestionFeed,
                onTapAnswer: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePostScreen(
                        onPostCreated: (post, isAlbumOnlyPost) {
                          widget.onPostCreatedFromHome?.call(
                            post,
                            isAlbumOnlyPost,
                          );
                          loadTodayQuestion();
                        },
                        dailyQuestion: todayQuestion,
                      ),
                    ),
                  );
                },
                onTapDismiss: () async {
                  await DailyQuestionService.instance.dismissToday();

                  if (!mounted) return;

                  setState(() {
                    todayQuestion = null;
                  });
                },
              )
            else
              const SizedBox(height: 16),

            Expanded(
              child: HomeFeedList(
                isLoadingPosts: _isLoadingPosts,
                hasMorePosts: _hasMorePosts,
                posts: posts,
                feedScrollController: feedScrollController,
                loadingController: _loadingController,
                commentCountOverrides: commentCountOverrides,
                scrappedPostIds: scrappedPostIds,
                onScrapTap: toggleScrap,
                onMoreTap: showPostMoreMenu,
                onReviewChanged: updatePostCommentCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
