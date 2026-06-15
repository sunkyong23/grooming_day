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
그루밍데이 개인정보처리방침

시행일: 2026.06.15

그루밍데이는 이용자의 개인정보를 중요하게 생각하며 관련 법령을 준수합니다.

1. 수집하는 개인정보

서비스는 다음 정보를 수집할 수 있습니다.

* 이메일 주소
* 사용자 아이디
* 프로필 이미지
* 반려묘 프로필 정보
* 게시글, 감상평 등 이용자가 작성한 콘텐츠

2. 개인정보 수집 목적

수집한 개인정보는 다음 목적을 위해 사용됩니다.

* 회원 식별 및 로그인
* 서비스 제공
* 고객 문의 응대
* 서비스 품질 개선
* 부정 이용 방지

3. 개인정보 보관 기간

회원 탈퇴 시 개인정보는 즉시 삭제하는 것을 원칙으로 합니다.

다만 관계 법령에 따라 보관이 필요한 경우 해당 기간 동안 보관할 수 있습니다.

4. 개인정보의 제3자 제공

서비스는 이용자의 개인정보를 외부에 판매하거나 제공하지 않습니다.

법령에 의한 경우를 제외하고 제3자에게 제공하지 않습니다.

5. 개인정보 처리 위탁

서비스 운영을 위해 다음 업체를 이용할 수 있습니다.

* Google Firebase (인증, 데이터 저장, 이미지 저장)

6. 이용자의 권리

이용자는 언제든지 자신의 개인정보를 조회, 수정 또는 삭제할 수 있습니다.

회원 탈퇴를 통해 개인정보 삭제를 요청할 수 있습니다.

7. 개인정보 보호

서비스는 개인정보 보호를 위해 합리적인 보안 조치를 적용합니다.

8. 문의

개인정보 관련 문의는 운영자 이메일을 통해 접수할 수 있습니다.

문의: groomingday.help@gmail.com


'''),
        ),
      ),
    );
  }
}
