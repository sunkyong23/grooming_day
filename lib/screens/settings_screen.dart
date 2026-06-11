import 'package:flutter/material.dart';

import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'notice_screen.dart';
import 'update_screen.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'blocked_users_screen.dart';
import 'admin_screen.dart';

import '../services/auth_service.dart';
import '../services/admin_service.dart';

class SettingsScreen extends StatefulWidget {
  final String email;
  final VoidCallback onDeleteAccountTap;

  const SettingsScreen({
    super.key,
    required this.email,
    required this.onDeleteAccountTap,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isAdmin = false;
  bool isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    final result = await AdminService.isCurrentUserAdmin();

    if (!mounted) return;

    setState(() {
      isAdmin = result;
      isCheckingAdmin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text('설정', style: TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (!isCheckingAdmin && isAdmin)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFFFF8A7A),
              ),
              title: const Text(
                '관리자 페이지',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D241E),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB08678),
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AdminScreen()));
              },
            ),

          if (!isCheckingAdmin && isAdmin) const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFF8A756C),
            ),
            title: const Text(
              '공지사항',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D241E),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB08678),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const NoticeScreen()));
            },
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.rocket_launch_rounded,
              color: Color(0xFF8A756C),
            ),
            title: const Text(
              '업데이트 내역',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D241E),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB08678),
            ),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const UpdateScreen()));
            },
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.person_off_outlined,
              color: Color(0xFF8A756C),
            ),
            title: const Text(
              '차단한 사용자',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D241E),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB08678),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
              );
            },
          ),

          const SizedBox(height: 32),

          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
            child: const Text('개인정보 처리방침'),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const TermsScreen()));
            },
            child: const Text('이용약관'),
          ),

          const SizedBox(height: 20),

          Text(
            '이메일\n${widget.email}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF8A756C)),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
            child: const Text('비밀번호 변경'),
          ),

          TextButton(
            onPressed: () async {
              await AuthService.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('로그아웃'),
          ),

          TextButton(
            onPressed: widget.onDeleteAccountTap,
            child: const Text('계정 탈퇴', style: TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
