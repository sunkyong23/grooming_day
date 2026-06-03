import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<CropAspectRatio?> showAspectRatioBottomSheet(BuildContext context) {
  return showModalBottomSheet<CropAspectRatio>(
    context: context,
    backgroundColor: const Color(0xFFFFF7F1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '사진 비율 선택',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),

            ListTile(
              leading: const Icon(Icons.crop_landscape),
              title: const Text('가로 4:3'),
              onTap: () {
                Navigator.pop(
                  context,
                  const CropAspectRatio(ratioX: 4, ratioY: 3),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.crop_portrait),
              title: const Text('세로 4:5'),
              onTap: () {
                Navigator.pop(
                  context,
                  const CropAspectRatio(ratioX: 4, ratioY: 5),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.crop_square),
              title: const Text('정사각형 1:1'),
              onTap: () {
                Navigator.pop(
                  context,
                  const CropAspectRatio(ratioX: 1, ratioY: 1),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
