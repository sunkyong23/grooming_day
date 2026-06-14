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

  Future<void> showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              color: Color(0xFF3D241E),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '정말 로그아웃 하시겠어요?',
            style: TextStyle(
              color: Color(0xFF5C4033),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Color(0xFF8A756C)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: Color(0xFFFF6F61),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await signOut();
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '설정',
          style: TextStyle(
            color: Color(0xFF4A2F26),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
        children: [
          if (!isCheckingAdmin && isAdmin) ...[
            _SettingsSection(
              title: '관리자',
              children: [
                _SettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: '관리자 페이지',
                  iconColor: const Color(0xFFFF8A7A),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          _SettingsSection(
            title: '앱 정보',
            children: [
              _SettingsTile(
                icon: Icons.campaign_rounded,
                title: '공지사항',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NoticeScreen()),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.rocket_launch_rounded,
                title: '업데이트 내역',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UpdateScreen()),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: '개인정보 처리방침',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.article_outlined,
                title: '이용약관',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsSection(
            title: '사용자 관리',
            children: [
              _SettingsTile(
                icon: Icons.person_off_outlined,
                title: '차단한 사용자',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BlockedUsersScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsSection(
            title: '계정',
            children: [
              _EmailTile(email: widget.email),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: '비밀번호 변경',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: '로그아웃',
                showChevron: false,
                onTap: showLogoutDialog,
              ),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: '계정 탈퇴',
                titleColor: const Color(0xFFFF5A5A),
                iconColor: const Color(0xFFFF5A5A),
                showChevron: false,
                onTap: widget.onDeleteAccountTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A756C),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Material(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(26),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 58),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFFEEDDD5).withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = const Color(0xFF8A756C),
    this.titleColor = const Color(0xFF3D241E),
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 25),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: titleColor,
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678))
          : null,
      onTap: onTap,
    );
  }
}

class _EmailTile extends StatelessWidget {
  final String email;

  const _EmailTile({required this.email});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: const Icon(
        Icons.email_outlined,
        color: Color(0xFF8A756C),
        size: 25,
      ),
      title: const Text(
        '이메일',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3D241E),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          email,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8A756C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
