import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<File?> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();

    final targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 60,
      minWidth: 1000,
      minHeight: 1000,
    );

    if (compressedFile == null) return null;

    return File(compressedFile.path);
  }

  static Future<File?> createThumbnail(File file) async {
    final tempDir = await getTemporaryDirectory();

    final targetPath =
        '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final thumbnailFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 40,
      minWidth: 300,
      minHeight: 300,
    );

    if (thumbnailFile == null) return null;

    return File(thumbnailFile.path);
  }
}
