import 'package:flutter/material.dart';

import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

import 'notice_screen.dart';
import 'update_screen.dart';
import 'login_screen.dart';

import 'change_password_screen.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  final String email;
  final VoidCallback onDeleteAccountTap;

  const SettingsScreen({
    super.key,
    required this.email,
    required this.onDeleteAccountTap,
  });

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
            '이메일\n$email',
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
            onPressed: onDeleteAccountTap,
            child: const Text('계정 탈퇴', style: TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
