import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosmed/viewmodels/user_viewmodel.dart';

class ProfileUpdateView extends StatefulWidget {
  const ProfileUpdateView({super.key});

  @override
  State<ProfileUpdateView> createState() => _ProfileUpdateViewState();
}

class _ProfileUpdateViewState extends State<ProfileUpdateView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  File? profilePath;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userVM = Provider.of<UserViewmodel>(context, listen: false);
      userVM.currentUser("post");
      nameController.text = "${userVM.mainUser?.name}";
      emailController.text = "${userVM.mainUser?.email}";
      bioController.text = userVM.mainUser?.bio ?? "";
    });
  }

  void onPicked() async {
    final pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedFile?.files.first.path != null) {
      setState(() {
        profilePath = File(pickedFile!.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewmodel>(context);
    final user = userVM.mainUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7643), Color(0xFFFF9E6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: Column(
                children: [
                  // Foto Profil
                  ProfilePic(
                    profilePath: profilePath?.path,
                    image: user.profile,
                    imageUploadBtnPress: onPicked,
                  ),
                  const SizedBox(height: 24),

                  // Form Input
                  Card(
                    elevation: 3,
                    shadowColor: Colors.orange.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20),
                      child: Column(
                        children: [
                          UserInfoEditField(
                            text: "Nama",
                            icon: Icons.person_outline,
                            child: TextFormField(
                              controller: nameController,
                              decoration: _inputStyle("Masukkan nama"),
                            ),
                          ),
                          const SizedBox(height: 12),
                          UserInfoEditField(
                            text: "Email",
                            icon: Icons.email_outlined,
                            child: TextFormField(
                              controller: emailController,
                              decoration: _inputStyle("Masukkan email"),
                            ),
                          ),
                          const SizedBox(height: 12),
                          UserInfoEditField(
                            text: "Bio",
                            icon: Icons.info_outline,
                            child: TextFormField(
                              controller: bioController,
                              decoration: _inputStyle("Masukkan bio"),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tombol Aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol batal
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tombol simpan
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7643),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 3,
                          ),
                          onPressed: userVM.isLoading
                              ? null
                              : () async {
                                  if (nameController.text.isNotEmpty &&
                                      emailController.text.isNotEmpty) {
                                    final response = await userVM.updateUser(
                                        user.id,
                                        nameController.text,
                                        emailController.text,
                                        bioController.text,
                                        profilePath?.path);
                                    AwesomeDialog(
                                            context: context,
                                            dialogType: response
                                                ? DialogType.success
                                                : DialogType.error,
                                            animType: AnimType.bottomSlide,
                                            dismissOnTouchOutside: false,
                                            title:
                                                response ? "Sukses" : "Error",
                                            desc: userVM.message,
                                            btnOkOnPress: () {
                                              if (response) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            btnOkColor: response
                                                ? Colors.green
                                                : Colors.red)
                                        .show();
                                  }
                                },
                          child: userVM.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  "Simpan",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

InputDecoration _inputStyle(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.orange.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color(0xFFFF7643), width: 1.5),
    ),
  );
}

class ProfilePic extends StatelessWidget {
  ProfilePic({
    this.image,
    this.profilePath,
    this.imageUploadBtnPress,
  });

  String? image;
  String? profilePath;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7643), Color(0xFFFF9E6D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: profilePath != null
                  ? Image.file(
                      File(profilePath!),
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        weight: 80,
                      ),
                    )
                  : image != null
                      ? CachedNetworkImage(
                          imageUrl: "http://10.0.2.2:9000/laravel/$image",
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey),
                        )
                      : const Icon(Icons.account_circle,
                          size: 110, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: InkWell(
            onTap: imageUploadBtnPress,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF7643),
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        )
      ],
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  const UserInfoEditField({
    super.key,
    required this.text,
    required this.child,
    required this.icon,
  });

  final String text;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFF7643), size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
