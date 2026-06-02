import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('''
그루밍데이 이용약관

제1조 (목적)
본 서비스는 반려묘 사진 및 기록을 공유하는 서비스를 제공합니다.

제2조 (회원의 의무)
타인의 권리를 침해하는 게시물을 등록할 수 없습니다.

제3조 (서비스 이용)
회원은 관련 법령을 준수해야 합니다.
            '''),
        ),
      ),
    );
  }
}
