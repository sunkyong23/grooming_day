import 'package:flutter/material.dart';

import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool isLoading = true;

  int userCount = 0;
  int postCount = 0;
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
      debugPrint('ADMIN users = $users');

      final posts = await AdminService.countCollection('posts');
      debugPrint('ADMIN posts = $posts');

      final reports = await AdminService.countReports();
      debugPrint('ADMIN reports = $reports');

      final userReports = await AdminService.countUserReports();
      debugPrint('ADMIN userReports = $userReports');

      if (!mounted) return;

      setState(() {
        userCount = users;
        postCount = posts;
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
    }
  }

  Widget buildStatCard({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                  buildStatCard(
                    title: '회원 수',
                    count: userCount,
                    icon: Icons.people_alt_outlined,
                  ),
                  const SizedBox(height: 14),
                  buildStatCard(
                    title: '게시글 수',
                    count: postCount,
                    icon: Icons.photo_library_outlined,
                  ),
                  const SizedBox(height: 14),
                  buildStatCard(
                    title: '게시글/감상평 신고',
                    count: reportCount,
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 14),
                  buildStatCard(
                    title: '사용자 신고',
                    count: userReportCount,
                    icon: Icons.person_off_outlined,
                  ),
                ],
              ),
            ),
    );
  }
}
