import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import 'admin_report_list_screen.dart';
import 'admin_user_report_list_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool isLoading = true;

  int userCount = 0;
  int postCount = 0;
  int reviewCount = 0;
  int rainbowLetterCount = 0;

  int todayUserCount = 0;
  int todayPostCount = 0;
  int todayReviewCount = 0;
  int todayRainbowLetterCount = 0;

  int reportCount = 0;
  int userReportCount = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final users = await AdminService.countCollection('users');
      final posts = await AdminService.countCollection('posts');
      final reviews = await AdminService.countReviews();
      final rainbowLetters = await AdminService.countRainbowLetters();

      final todayUsers = await AdminService.countTodayCollection('users');
      final todayPosts = await AdminService.countTodayCollection('posts');
      final todayReviews = await AdminService.countTodayReviews();
      final todayRainbowLetters = await AdminService.countTodayRainbowLetters();

      final reports = await AdminService.countReports();
      final userReports = await AdminService.countUserReports();

      if (!mounted) return;

      setState(() {
        userCount = users;
        postCount = posts;
        reviewCount = reviews;
        rainbowLetterCount = rainbowLetters;

        todayUserCount = todayUsers;
        todayPostCount = todayPosts;
        todayReviewCount = todayReviews;
        todayRainbowLetterCount = todayRainbowLetters;

        reportCount = reports;
        userReportCount = userReports;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ADMIN ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('관리자 통계를 불러오지 못했어요: $e')));
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: Color(0xFF3D241E),
        ),
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF8A7A), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5C4033),
              ),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D241E),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(onTap: onTap, child: card);
  }

  Widget buildStatGrid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: children,
    );
  }

  Future<void> openReportList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminReportListScreen()),
    );

    if (!mounted) return;
    await loadStats();
  }

  Future<void> openUserReportList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminUserReportListScreen()),
    );

    if (!mounted) return;
    await loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text(
          '관리자 페이지',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadStats,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  buildSectionTitle('📊 서비스 현황'),
                  buildStatGrid([
                    buildStatCard(
                      title: '회원 수',
                      count: userCount,
                      icon: Icons.people_alt_outlined,
                    ),
                    buildStatCard(
                      title: '게시글 수',
                      count: postCount,
                      icon: Icons.photo_library_outlined,
                    ),
                    buildStatCard(
                      title: '감상평 수',
                      count: reviewCount,
                      icon: Icons.chat_bubble_outline,
                    ),
                    buildStatCard(
                      title: '무지개별',
                      count: rainbowLetterCount,
                      icon: Icons.auto_awesome_outlined,
                    ),
                  ]),

                  const SizedBox(height: 10),

                  buildSectionTitle('🌱 오늘 활동'),
                  buildStatGrid([
                    buildStatCard(
                      title: '신규 가입',
                      count: todayUserCount,
                      icon: Icons.person_add_alt_1_outlined,
                    ),
                    buildStatCard(
                      title: '작성 게시글',
                      count: todayPostCount,
                      icon: Icons.add_photo_alternate_outlined,
                    ),
                    buildStatCard(
                      title: '작성 감상평',
                      count: todayReviewCount,
                      icon: Icons.mode_comment_outlined,
                    ),
                    buildStatCard(
                      title: '무지개별 편지',
                      count: todayRainbowLetterCount,
                      icon: Icons.star_border_rounded,
                    ),
                  ]),

                  const SizedBox(height: 10),

                  buildSectionTitle('🚨 신고 관리'),
                  buildStatCard(
                    title: '게시글/감상평 신고',
                    count: reportCount,
                    icon: Icons.flag_outlined,
                    onTap: openReportList,
                  ),
                  const SizedBox(height: 14),
                  buildStatCard(
                    title: '사용자 신고',
                    count: userReportCount,
                    icon: Icons.person_off_outlined,
                    onTap: openUserReportList,
                  ),
                ],
              ),
            ),
    );
  }
}
