import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(Post) onPostCreated;
  final File? initialImage;

  const CreatePostScreen({
    super.key,
    required this.onPostCreated,
    this.initialImage,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

Future<File?> compressImage(File file) async {
  final dir = await getTemporaryDirectory();

  final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 60,
    minWidth: 1000,
    minHeight: 1000,
  );

  if (compressedFile == null) {
    return null;
  }

  return File(compressedFile.path);
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();
  double selectedAspectRatio = 4 / 5;
  final List<String> tags = [
    '아깽이',
    '어르신',
    '장난꾸러기',
    '사랑스러운',
    '귀여워',
    '행복해',
    '일상',
    '평온한하루',
    '식빵굽기',
    '발라당',
    '심기불편',
    '사고뭉치',
    '정말못말려',
  ];

  final List<String> selectedTags = [];
  String currentUserId = 'groomingday23';
  Future<File?> pickAndCropImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
    );

    if (croppedFile == null) return null;

    return File(croppedFile.path);
  }

  @override
  void initState() {
    super.initState();

    loadCurrentUserId();

    if (widget.initialImage != null) {
      selectedImage = widget.initialImage;
    }
  }

  Future<void> loadCurrentUserId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      setState(() {
        currentUserId = doc.data()?['userId'] ?? 'groomingday23';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF7F1),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('게시글 작성'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              GestureDetector(
                onTap: () async {
                  // print('사진 영역 클릭됨!');
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image == null) return;
                  if (!context.mounted) return;

                  final ratio = await showModalBottomSheet<double>(
                    context: context,
                    builder: (bottomSheetContext) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ListTile(
                              title: Text(
                                '사진 비율 선택',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              title: const Text('가로형 4:3'),
                              onTap: () =>
                                  Navigator.pop(bottomSheetContext, 4 / 3),
                            ),
                            ListTile(
                              title: const Text('세로형 4:5'),
                              onTap: () =>
                                  Navigator.pop(bottomSheetContext, 4 / 5),
                            ),
                            ListTile(
                              title: const Text('정사각형 1:1'),
                              onTap: () =>
                                  Navigator.pop(bottomSheetContext, 1.0),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (ratio == null) return;

                  selectedAspectRatio = ratio;

                  final croppedFile = await ImageCropper().cropImage(
                    sourcePath: image.path,
                    aspectRatio: CropAspectRatio(
                      ratioX: ratio == 4 / 3
                          ? 4
                          : ratio == 1.0
                          ? 1
                          : 4,
                      ratioY: ratio == 4 / 3
                          ? 3
                          : ratio == 1.0
                          ? 1
                          : 5,
                    ),
                  );

                  if (croppedFile != null) {
                    setState(() {
                      selectedImage = File(croppedFile.path);
                    });
                  }
                },

                child: Container(
                  constraints: BoxConstraints(
                    minHeight: selectedImage == null ? 220 : 0,
                    maxHeight: selectedImage == null ? 260 : double.infinity,
                  ),
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: selectedImage == null
                      ? const Center(
                          child: Icon(Icons.add_photo_alternate, size: 60),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: captionController,

                maxLines: 3,

                decoration: InputDecoration(
                  hintText: '우리 냥이를 소개해 주세요 🐱',

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('태그 선택 (최대 3개)'),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: tags.map((tag) {
                  final selected = selectedTags.contains(tag);

                  return FilterChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF4A2B22)
                            : const Color(0xFF8C6A5F),
                      ),
                    ),

                    selected: selected,

                    showCheckmark: false,

                    selectedColor: const Color(0xFFFFE9DE),

                    backgroundColor: Colors.white,

                    side: BorderSide(
                      color: selected
                          ? const Color(0xFFF5A88B)
                          : const Color(0xFFE8E1DB),
                    ),

                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          selectedTags.remove(tag);
                        } else {
                          if (selectedTags.length < 3) {
                            selectedTags.add(tag);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedImage == null) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final postId = FirebaseFirestore.instance
                        .collection('posts')
                        .doc()
                        .id;

                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('posts')
                        .child(user.uid)
                        .child('$postId.jpg');

                    final compressedImage = await compressImage(selectedImage!);

                    final uploadFile = compressedImage ?? selectedImage!;

                    await storageRef.putFile(uploadFile);

                    final imageUrl = await storageRef.getDownloadURL();

                    final newPost = Post(
                      id: postId,
                      imageUrl: imageUrl,
                      caption: captionController.text,
                      likes: 0,
                      tags: selectedTags,
                      createdAt: DateTime.now(),
                      aspectRatio: selectedAspectRatio,
                      catName: '가을이',
                      userId: currentUserId,
                      isAsset: false,
                    );

                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .set({
                          'id': postId,
                          'imageUrl': imageUrl,
                          'caption': captionController.text,
                          'likes': 0,
                          'tags': selectedTags,
                          'createdAt': Timestamp.now(),
                          'aspectRatio': selectedAspectRatio,
                          'catName': '가을이',
                          'userId': currentUserId,
                          'ownerUid': user.uid,
                        });

                    widget.onPostCreated(newPost);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },

                  child: const Text('게시하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
