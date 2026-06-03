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
              SizedBox(height: 6),
              Text(
                '오늘도 너와 함께하는 하루',
                style: TextStyle(fontSize: 16, color: Color(0xFF5E3D35)),
              ),
            ],
          ),
        ),
        HeaderIcon(icon: Icons.notifications_none_rounded),
        SizedBox(width: 10),
        HeaderIcon(icon: Icons.photo_camera_outlined, onTap: onCameraTap),
      ],
    );
  }
}
