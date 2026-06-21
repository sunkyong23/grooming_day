import 'package:flutter/material.dart';

import '../../models/post.dart';
import '../../services/report_service.dart';

Future<void> showPostReportDialog({
  required BuildContext context,
  required Post post,
}) async {
  String selectedReason = '부적절한 사진';
  final descriptionController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> showReasonBottomSheet() async {
            final reason = await showModalBottomSheet<String>(
              context: dialogContext,
              backgroundColor: const Color(0xFFFFF8F2),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (sheetContext) {
                final reasons = [
                  '부적절한 사진',
                  '불쾌한 내용',
                  '스팸/홍보',
                  '비방/욕설',
                  '개인정보 노출',
                  '기타',
                ];

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 18),
                        ...reasons.map((reason) {
                          final isSelected = selectedReason == reason;

                          return ListTile(
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -2),
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: const Color(0xFF5C4033),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFFE8A58A),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(sheetContext, reason);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );

            if (reason == null) return;

            setDialogState(() {
              selectedReason = reason;
            });
          }

          return AlertDialog(
            backgroundColor: const Color(0xFFFFF8F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            title: const Text(
              '게시글 신고',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5C4033),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: showReasonBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3E3DA)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedReason,
                            style: const TextStyle(
                              color: Color(0xFF5C4033),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF8A756C),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  cursorColor: const Color(0xFF8A5A44),
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(
                    color: Color(0xFF5A372F),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '신고 내용을 자세히 적어주세요.',
                    hintStyle: const TextStyle(color: Color(0xFFC9B8AE)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8A58A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.only(right: 20, bottom: 12),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Color(0xFF8A756C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text(
                  '신고',
                  style: TextStyle(
                    color: Color(0xFFFF7A7A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != true) {
    descriptionController.dispose();
    return;
  }

  try {
    await ReportService.createReport(
      targetType: 'post',
      targetId: post.id,
      targetOwnerUid: post.ownerUid,
      reason: selectedReason,
      description: descriptionController.text,
    );

    descriptionController.dispose();

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
  } catch (e) {
    debugPrint('게시글 신고 오류: $e');

    descriptionController.dispose();

    if (!context.mounted) return;

    final message = e.toString().contains('이미 신고한 항목')
        ? '이미 신고한 게시글이에요.'
        : '신고 접수 중 오류가 발생했어요. 잠시 후 다시 시도해주세요.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
