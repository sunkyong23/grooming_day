import 'package:flutter/material.dart';

import 'header_icon.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

import '../screens/notification_screen.dart';

class Header extends StatelessWidget {
  final VoidCallback onCameraTap;

  final bool communityBgmEnabled;
  final VoidCallback onCommunityBgmTap;

  const Header({
    super.key,
    required this.onCameraTap,
    required this.communityBgmEnabled,
    required this.onCommunityBgmTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '그루밍데이',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 43,
                      color: Color(0xFF351A14),
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onCommunityBgmTap,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AnimatedOpacity(
                        opacity: communityBgmEnabled ? 1.0 : 0.28,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.music_note_rounded,
                          size: 22,
                          color: Color(0xFF5E3D35),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '오늘도 너와 함께하는 하루',
                style: TextStyle(fontSize: 14, color: Color(0xFF5E3D35)),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 42,
          height: 42,
          child: StreamBuilder<bool>(
            stream: NotificationService().hasUnreadNotification(
              FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
            builder: (context, snapshot) {
              final hasUnread = snapshot.data ?? false;

              return IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 24,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 28,
                      color: Color(0xFF5E3D35),
                    ),
                    if (hasUnread)
                      Positioned(
                        top: 2,
                        right: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF7F7F),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        HeaderIcon(icon: Icons.photo_camera_outlined, onTap: onCameraTap),
      ],
    );
  }
}
