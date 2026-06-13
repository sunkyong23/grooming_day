import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';
import '../services/block_service.dart';
import '../services/user_report_service.dart';
import 'cat_profile_detail_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String bio;
  final String profileImageUrl;
  final String ownerUid;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.bio,
    required this.profileImageUrl,
    required this.ownerUid,
  });

  Future<void> showUserReportDialog(BuildContext context) async {
    String selectedReason = '불쾌한 사용자';
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> showReasonBottomSheet() async {
              final reason = await showModalBottomSheet<String>(
                context: dialogContext,
                backgroundColor: const Color(0xFFFFF8F2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (sheetContext) {
                  final reasons = [
                    '불쾌한 사용자',
                    '스팸/홍보',
                    '비방/욕설',
                    '개인정보 노출',
                    '기타',
                  ];

                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: reasons.map((reason) {
                          final isSelected = selectedReason == reason;

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: const Color(0xFF5C4033),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFFE8A58A),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(sheetContext, reason);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );

              if (reason == null) return;

              setDialogState(() {
                selectedReason = reason;
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFFFF8F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              title: const Text(
                '사용자 신고',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5C4033),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: showReasonBottomSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3E3DA)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedReason,
                              style: const TextStyle(
                                color: Color(0xFF5C4033),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF8A756C),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: descriptionController,
                    cursorColor: const Color(0xFF8A5A44),
                    maxLines: 3,
                    maxLength: 200,
                    style: const TextStyle(
                      color: Color(0xFF5A372F),
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: '신고 내용을 자세히 적어주세요.',
                      hintStyle: const TextStyle(color: Color(0xFFC9B8AE)),
                      filled: true,
                      fillColor: Colors.white,
                      counterStyle: const TextStyle(color: Color(0xFF8A756C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE8A58A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.only(right: 20, bottom: 12),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFF8A756C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text(
                    '신고',
                    style: TextStyle(
                      color: Color(0xFFFF7A7A),
                      fontWeight: FontWeight.w700,
                    ),
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
        targetUid: ownerUid,
        targetUserId: userId,
        reason: selectedReason,
        detail: descriptionController.text,
      );

      descriptionController.dispose();

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사용자 신고가 접수되었습니다.')));
    } catch (e) {
      descriptionController.dispose();

      if (!context.mounted) return;

      final message = e.toString().contains('이미 신고한 사용자')
          ? '이미 신고한 사용자예요.'
          : e.toString().contains('본인은 신고할 수')
          ? '본인은 신고할 수 없어요.'
          : '신고 접수 중 오류가 발생했어요.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> showBlockDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          title: const Text(
            '사용자 차단',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5C4033),
            ),
          ),
          content: Text(
            '@$userId 님을 차단할까요?\n\n'
            '차단하면 이 사용자의 게시글과 감상평이\n'
            '더 이상 보이지 않아요.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Color(0xFF5A372F),
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 20, bottom: 12),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF8A756C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                '차단',
                style: TextStyle(
                  color: Color(0xFFFF7A7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await BlockService.blockUser(blockedUid: ownerUid, blockedUserId: userId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('@$userId 사용자를 차단했습니다.')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMyProfile = FirebaseAuth.instance.currentUser?.uid == ownerUid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!isMyProfile)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF5C4033)),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFFFFF8F2),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  builder: (bottomSheetContext) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.flag_outlined,
                                color: Color(0xFFFF7A7A),
                              ),
                              title: const Text(
                                '사용자 신고',
                                style: TextStyle(
                                  color: Color(0xFFFF7A7A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(bottomSheetContext);

                                await Future.delayed(
                                  const Duration(milliseconds: 150),
                                );

                                if (!context.mounted) return;

                                await showUserReportDialog(context);
                              },
                            ),

                            ListTile(
                              leading: const Icon(
                                Icons.block_outlined,
                                color: Color(0xFFFF7A7A),
                              ),
                              title: const Text(
                                '사용자 차단',
                                style: TextStyle(
                                  color: Color(0xFFFF7A7A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(bottomSheetContext);

                                await Future.delayed(
                                  const Duration(milliseconds: 150),
                                );

                                if (!context.mounted) return;

                                await showBlockDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFFFE2C6),
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),

            const SizedBox(height: 16),

            Text(
              '@$userId',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D241E),
              ),
            ),

            const SizedBox(height: 8),

            if (bio.isNotEmpty)
              Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF8C6A5F)),
              ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '내 고양이',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<CatProfile>>(
              future: CatService.loadPublicCatsByOwnerUid(ownerUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    '고양이 목록을 불러오지 못했어요 🐾',
                    style: TextStyle(
                      color: Color(0xFFB08678),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                final cats = snapshot.data ?? [];

                if (cats.isEmpty) {
                  return const Text(
                    '공개된 고양이 프로필이 없어요 🐾',
                    style: TextStyle(
                      color: Color(0xFFB08678),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                return Column(
                  children: cats.map((cat) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CatProfileDetailScreen(cat: cat),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFFFFE2C6),
                              backgroundImage:
                                  !cat.isVirtualCat &&
                                      cat.profileImageUrl.isNotEmpty
                                  ? NetworkImage(cat.profileImageUrl)
                                  : null,
                              child: cat.isVirtualCat
                                  ? Image.asset(
                                      'assets/icons/today_cat.png',
                                      width: 34,
                                      height: 34,
                                    )
                                  : cat.profileImageUrl.isEmpty
                                  ? const Icon(Icons.pets)
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3D241E),
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFB08678),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
