import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 처리방침')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('''
개인정보 처리방침

그루밍데이는 회원가입 시 이메일, 사용자 아이디 정보를 저장합니다.

수집된 정보는 서비스 제공 목적 외에는 사용하지 않습니다.

회원 탈퇴 시 관련 정보는 삭제됩니다.
'''),
        ),
      ),
    );
  }
}
