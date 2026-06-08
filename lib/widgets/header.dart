import 'package:flutter/material.dart';

import 'header_icon.dart';

class Header extends StatelessWidget {
  final VoidCallback onCameraTap;

  const Header({super.key, required this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '그루밍데이',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF351A14),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '오늘도 너와 함께하는 하루',
                style: TextStyle(fontSize: 16, color: Color(0xFF5E3D35)),
              ),
            ],
          ),
        ),

        // 알림 아이콘 (배경 없음)
        SizedBox(
          width: 42,
          height: 42,
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: 24,
            onPressed: () {
              // TODO: 알림 화면 이동
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: Color(0xFF5E3D35),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 카메라 아이콘 (기존 핑크 박스 유지)
        HeaderIcon(icon: Icons.photo_camera_outlined, onTap: onCameraTap),
      ],
    );
  }
}
