import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/app_notification.dart';

import '../services/notification_service.dart';
import '../services/post_service.dart';
import '../services/notice_service.dart';
import '../services/update_service.dart';

import '../widgets/post_detail_dialog.dart';

import 'notice_detail_screen.dart';
import 'update_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null && uid.isNotEmpty) {
        await notificationService.markAllAsRead(uid);
      }
    });
  }

  Future<void> handleNotificationTap(AppNotification notification) async {
    if (notification.type == 'notice') {
      final noticeData = await NoticeService.loadNoticeById(
        notification.targetNoticeId,
      );

      if (noticeData == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('공지를 찾을 수 없어요.')));
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoticeDetailScreen(
            title: noticeData['title'] ?? '공지',
            content: noticeData['content'] ?? '',
          ),
        ),
      );
      return;
    }

    if (notification.type == 'update') {
      final updateData = await UpdateService.loadUpdateById(
        notification.targetUpdateId,
      );

      if (updateData == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('업데이트 소식을 찾을 수 없어요.')));
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UpdateDetailScreen(
            version: updateData['version'] ?? '업데이트',
            title: updateData['title'] ?? '업데이트 소식',
            content: updateData['content'] ?? '',
          ),
        ),
      );
      return;
    }

    final post = await PostService.loadPostById(notification.targetPostId);

    if (post == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글을 찾을 수 없어요.')));
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => PostDetailDialog(
        imageUrl: post.imageUrl,
        catName: post.catName,
        caption: post.caption,
        postId: post.id,
        createdAt: post.createdAt ?? DateTime.now(),
        tagText: post.tags.map((tag) => '#$tag').join(' '),
        canWriteReview: post.ownerUid != FirebaseAuth.instance.currentUser?.uid,
      ),
    );
  }

  Widget buildNotificationImage(AppNotification notification) {
    if (notification.type == 'notice') {
      return Container(
        width: 48,
        height: 48,
        color: const Color(0xFFFFEFE6),
        alignment: Alignment.center,
        child: const Icon(
          Icons.campaign_outlined,
          size: 24,
          color: Color(0xFF8A5A44),
        ),
      );
    }

    if (notification.type == 'update') {
      return Container(
        width: 48,
        height: 48,
        color: const Color(0xFFFFEFE6),
        alignment: Alignment.center,
        child: const Icon(
          Icons.system_update_alt_rounded,
          size: 24,
          color: Color(0xFF8A5A44),
        ),
      );
    }

    if (notification.targetImageUrl.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        color: const Color(0xFFFFEFE6),
        alignment: Alignment.center,
        child: const Text('🐾'),
      );
    }

    return CachedNetworkImage(
      imageUrl: notification.targetImageUrl,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Container(
          width: 48,
          height: 48,
          color: const Color(0xFFFFEFE6),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          width: 48,
          height: 48,
          color: const Color(0xFFFFEFE6),
          alignment: Alignment.center,
          child: const Text('🐾'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF7F1),
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('알림'),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: notificationService.watchMyNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '알림을 불러오지 못했어요.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A6B60),
                  ),
                ),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting &&
              notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                '새로운 알림이 없어요 🐾',
                style: TextStyle(fontSize: 13, color: Color(0xFF9A6B60)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return GestureDetector(
                onTap: () async {
                  await handleNotificationTap(notification);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: buildNotificationImage(notification),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3D241E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A6A5F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
