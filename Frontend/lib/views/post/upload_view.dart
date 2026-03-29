import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosmed/viewmodels/post_viewmodel.dart';
import 'package:sosmed/views/main/footer_view.dart';
import 'package:video_player/video_player.dart';

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  VideoPlayerController? _videoController;
  List<String> imagePath = [];
  String? videoPath;
  String? thumbnailPath;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  final typeController = TextEditingController();
  final captionController = TextEditingController();

  Map<String, String> typeOptions = {
    "image": "Postingan Gambar",
    "video": "Postingan Video"
  };

  /// 🔥 PICK IMAGE
  // void pickImage() async {
  //   final picked = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //     allowMultiple: true,
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       imagePath = picked.files.map((e) => e.path!).toList();
  //     });
  //   }
  // }
  void pickImage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (picked != null) {
      setState(() {
        imagePath.add(picked.files.first.path!);
      });
    }
  }

  /// 🔥 PICK VIDEO
  void pickVideo() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.video);

    if (picked?.files.first.path != null) {
      videoPath = picked!.files.first.path!;

      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });

      setState(() {});
    }
  }

  /// 🔥 PICK THUMBNAIL
  void pickThumbnail() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked?.files.first.path != null) {
      setState(() {
        thumbnailPath = picked!.files.first.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postVM = Provider.of<PostViewmodel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      /// 🔥 APPBAR PREMIUM
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade400],
            ),
          ),
        ),
        title: const Text("Buat Postingan",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔥 TYPE DROPDOWN (CARD STYLE)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: typeController.text.isNotEmpty
                    ? typeController.text
                    : null,
                items: typeOptions.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    typeController.text = val!;
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Pilih tipe postingan",
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 IMAGE PREVIEW MULTI (SCROLL)
            if (typeController.text == "image")
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagePath.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildAddBox(
                        icon: Icons.add_photo_alternate,
                        label: "Tambah",
                        onTap: pickImage,
                      );
                    }

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(imagePath[index - 1]),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// 🔥 DELETE BUTTON
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                imagePath.removeAt(index - 1);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            /// 🔥 VIDEO UI
            if (typeController.text == "video") ...[
              _buildAddBox(
                icon: Icons.image,
                label: "Thumbnail",
                onTap: pickThumbnail,
                image: thumbnailPath,
              ),
              const SizedBox(height: 12),
              _buildVideoPreview(),
            ],

            const SizedBox(height: 20),

            /// 🔥 CAPTION (PREMIUM)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: TextField(
                controller: captionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Tulis caption...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔥 BUTTON
            Row(
              children: [

                /// CANCEL
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FooterView(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Batal"),
                  ),
                ),

                const SizedBox(width: 12),

                /// UPLOAD
                Expanded(
                  child: ElevatedButton(
                    onPressed: postVM.isLoading
                        ? null
                        : () async {
                            final response = await postVM.uploadPost(
                              captionController.text,
                              typeController.text,
                              imagePath,
                              videoPath,
                              thumbnailPath,
                            );

                            AwesomeDialog(
                              context: context,
                              dialogType: response
                                  ? DialogType.success
                                  : DialogType.error,
                              title: response ? "Sukses" : "Error",
                              desc: postVM.message,
                              btnOkOnPress: () {
                                if(response){
                                  Navigator.pushAndRemoveUntil(
                                    context, MaterialPageRoute(builder: (context) => FooterView()), (route) => false);
                                }
                              },
                              btnOkColor: response ? Colors.green : Colors.red
                            ).show();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.orange.shade700,
                    ),
                    child: postVM.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Upload"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 🔥 COMPONENT ADD BOX (REUSABLE)
  Widget _buildAddBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? image,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [Colors.orange.shade700, Colors.orange.shade400],
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(image), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(height: 6),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (videoPath == null) {
      return _buildAddBox(
        icon: Icons.video_call,
        label: "Pilih Video",
        onTap: pickVideo,
      );
    }

    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _videoController != null &&
                    _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),

        /// 🔥 PLAY BUTTON
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),

        /// 🔥 DELETE BUTTON
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                videoPath = null;
                _videoController?.dispose();
                _videoController = null;
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}