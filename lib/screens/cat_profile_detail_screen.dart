import 'package:flutter/material.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';

import '../models/post.dart';
import '../services/post_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'edit_cat_profile_screen.dart';

import '../services/favorite_cat_service.dart';
import '../widgets/post_detail_dialog.dart';

import 'package:cached_network_image/cached_network_image.dart';

class CatProfileDetailScreen extends StatefulWidget {
  final CatProfile cat;

  const CatProfileDetailScreen({super.key, required this.cat});

  @override
  State<CatProfileDetailScreen> createState() => _CatProfileDetailScreenState();
}

class _CatProfileDetailScreenState extends State<CatProfileDetailScreen> {
  List<Post> catPosts = [];
  bool isFavoriteCat = false;
  bool isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    loadCatPosts();
    loadFavoriteState();
  }

  Future<void> _showOwnerMenu() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFFF8F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7D6CE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                _ownerMenuItem(
                  icon: Icons.edit_rounded,
                  title: '프로필 수정',
                  onTap: () => Navigator.pop(sheetContext, 'edit'),
                ),

                _ownerMenuItem(
                  icon: widget.cat.isHidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  title: widget.cat.isHidden ? '숨김 해제' : '숨기기',
                  onTap: () => Navigator.pop(
                    sheetContext,
                    widget.cat.isHidden ? 'unhide' : 'hide',
                  ),
                ),

                const Divider(height: 20, color: Color(0xFFEADDD5)),

                _ownerMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: '프로필 삭제',
                  color: Colors.redAccent,
                  onTap: () => Navigator.pop(sheetContext, 'delete'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;
    if (!mounted) return;

    final navigator = Navigator.of(context);

    if (result == 'edit') {
      final editResult = await navigator.push(
        MaterialPageRoute(
          builder: (_) => EditCatProfileScreen(cat: widget.cat),
        ),
      );

      if (editResult == true) {
        if (!mounted) return;
        navigator.pop(true);
      }
    }

    if (result == 'hide') {
      final confirm = await _showHideConfirmDialog();
      if (!confirm) return;

      await CatService.hideCatProfile(widget.cat.id);

      if (!mounted) return;
      navigator.pop(true);
    }

    if (result == 'unhide') {
      await CatService.unhideCatProfile(widget.cat.id);

      if (!mounted) return;
      navigator.pop(true);
    }

    if (result == 'delete') {
      final confirm = await _showDeleteConfirmDialog();
      if (!confirm) return;

      await CatService.deleteCatProfile(widget.cat.id);

      if (!mounted) return;
      navigator.pop(true);
    }
  }

  Widget _ownerMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF4A2B22),
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> toggleFavoriteCat() async {
    if (isFavoriteLoading) return;

    setState(() {
      isFavoriteLoading = true;
    });

    try {
      if (isFavoriteCat) {
        await FavoriteCatService.removeFavoriteCat(widget.cat.id);
      } else {
        await FavoriteCatService.addFavoriteCat(
          catProfileId: widget.cat.id,
          ownerUid: widget.cat.ownerUid,
          catName: widget.cat.name,
          catProfileImageUrl: widget.cat.profileImageUrl,
          ownerUserId: widget.cat.ownerUserId,
        );
      }

      if (!mounted) return;

      setState(() {
        isFavoriteCat = !isFavoriteCat;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavoriteCat
                ? '꾹꾹 완료! 내 프로필의 꾹꾹 고양이에서 확인할 수 있어요 🐾'
                : '꾹꾹을 취소했어요.',
          ),
          backgroundColor: const Color(0xFF333333),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isFavoriteLoading = false;
        });
      }
    }
  }

  Future<void> loadFavoriteState() async {
    final result = await FavoriteCatService.isFavoriteCat(widget.cat.id);

    if (!mounted) return;

    setState(() {
      isFavoriteCat = result;
    });
  }

  Future<void> loadCatPosts() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMyCat = widget.cat.ownerUid == currentUid;

    final posts = await PostService.loadPostsByCatProfile(
      widget.cat.id,
      includePrivate: isMyCat,
    );

    if (!mounted) return;

    setState(() {
      catPosts = posts;
    });
  }

  String getCatAge(DateTime? birthDate) {
    if (birthDate == null) {
      return '나이 정보 없음';
    }

    final now = DateTime.now();

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (now.day < birthDate.day) {
      months -= 1;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years <= 0) {
      return '$months개월';
    }

    if (months == 0) {
      return '$years살';
    }

    return '$years살 $months개월';
  }

  String getBirthDateText(DateTime? birthDate) {
    if (birthDate == null) {
      return '생일 정보 없음';
    }

    return '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _showHideConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            '고양이 프로필 숨기기',
            style: TextStyle(
              color: Color(0xFF4A2B22),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            '숨긴 프로필은 홈과 검색에서 보이지 않아요.\n언제든 다시 표시할 수 있어요.',
            style: TextStyle(
              color: Color(0xFF6F5A52),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF8C6A5F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                '숨기기',
                style: TextStyle(
                  color: Color(0xFF7B5146),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            '고양이 프로필 삭제',
            style: TextStyle(
              color: Color(0xFF4A2B22),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            '정말 삭제할까요?\n삭제 후에는 다시 복구할 수 없어요.',
            style: TextStyle(
              color: Color(0xFF6F5A52),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF8C6A5F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.cat.ownerUid;

    final canFavorite = !isOwner;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (canFavorite)
            GestureDetector(
              onTap: toggleFavoriteCat,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  isFavoriteCat
                      ? 'assets/icons/paw_fill.png'
                      : 'assets/icons/paw_outline.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),

          if (isOwner)
            IconButton(
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF5C4033),
              ),
              onPressed: () {
                _showOwnerMenu();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage:
                    !widget.cat.isVirtualCat &&
                        widget.cat.profileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(widget.cat.profileImageUrl)
                    : null,
                child: widget.cat.isVirtualCat
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/icons/today_cat.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : widget.cat.profileImageUrl.isEmpty
                    ? const Icon(Icons.pets, size: 36)
                    : null,
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                widget.cat.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F1A24),
                ),
              ),
            ),

            if (widget.cat.ownerUserId.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '@${widget.cat.ownerUserId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB08678),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (widget.cat.introduction.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  widget.cat.introduction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF4A2B22),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (widget.cat.personalityTags.isNotEmpty) ...[
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.cat.personalityTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9DE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8C6A5F),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (!widget.cat.isVirtualCat)
              _catInfoCard(
                breed: widget.cat.breed.isEmpty ? '미입력' : widget.cat.breed,
                gender: widget.cat.gender,
                birthDate: getBirthDateText(widget.cat.birthDate),
              ),

            const SizedBox(height: 18),

            const Text(
              '앨범',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1A24),
              ),
            ),

            const SizedBox(height: 8),

            catPosts.isEmpty
                ? Container(
                    height: 150,
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
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                    itemBuilder: (context, index) {
                      final post = catPosts[index];

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
                              tagText: post.tags
                                  .map((tag) => '#$tag')
                                  .join(' '),
                              canWriteReview:
                                  post.ownerUid !=
                                  FirebaseAuth.instance.currentUser?.uid,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: post.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Container(
                                color: const Color(0xFFFFEFE6),
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: const Color(0xFFFFEFE6),
                                alignment: Alignment.center,
                                child: const Text('🐾'),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _catInfoCard({
    required String breed,
    required String gender,
    required String birthDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            _catInfoRow(icon: Icons.pets_outlined, title: '품종', value: breed),
            _catInfoDivider(),
            _catInfoRow(icon: Icons.male_rounded, title: '성별', value: gender),
            _catInfoDivider(),
            _catInfoRow(
              icon: Icons.calendar_today_outlined,
              title: '생일',
              value: birthDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _catInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Color(0xFF8A5A44)),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 52,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A2B22),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3D241E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catInfoDivider() {
    return Container(height: 0.7, color: const Color(0xFFF1E6E1));
  }
}
