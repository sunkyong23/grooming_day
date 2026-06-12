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
          title: const Text('사용자 차단'),
          content: Text(
            '@$userId 사용자를 차단할까요?\n\n'
            '차단하면 해당 사용자의 게시글과 감상평이 보이지 않게 됩니다.',
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
                '차단',
                style: TextStyle(color: Colors.redAccent),
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF5C4033)),
              onSelected: (value) async {
                if (value == 'report') {
                  await showUserReportDialog(context);
                }

                if (value == 'block') {
                  await showBlockDialog(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'report', child: Text('사용자 신고')),
                PopupMenuItem(value: 'block', child: Text('사용자 차단')),
              ],
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
