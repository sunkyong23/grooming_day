import 'package:flutter/material.dart';
import '../models/cat_profile.dart';
import '../services/cat_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        scrolledUnderElevation: 0,
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
