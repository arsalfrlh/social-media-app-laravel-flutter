import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosmed/models/user.dart';
import 'package:sosmed/viewmodels/post_viewmodel.dart';
import 'package:sosmed/viewmodels/reaction_viewmodel.dart';

class CommentView extends StatefulWidget {
  const CommentView({required this.currentUser, required this.postId, required this.onClose});
  final User currentUser;
  final int postId;
  final VoidCallback onClose;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask((){
      final postVM = Provider.of<PostViewmodel>(context, listen: false);
      postVM.showPost(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postVM = Provider.of<PostViewmodel>(context);
    final reactVM = Provider.of<ReactionViewmodel>(context);

    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                // === HEADER KOMENTAR ===
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.deepOrangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Komentar Pengguna",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),

                // === DAFTAR KOMENTAR ===
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: postVM.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.orange),
                          )
                        : postVM.currentPost?.comment == null || postVM.currentPost!.comment!.isEmpty
                            ? const Center(
                                child: Text(
                                  "Belum ada komentar.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: postVM.currentPost!.comment!.length,
                                itemBuilder: (context, index) {
                                  final userComment = postVM.currentPost!.comment![index].user;
                                  final comment = postVM.currentPost!.comment![index];
                                  final bool isMine = userComment.id == widget.currentUser.id;

                                  return AnimatedOpacity(
                                    opacity: 1,
                                    duration: Duration(milliseconds: 300 + (index * 80)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        mainAxisAlignment: isMine
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Avatar lawan bicara
                                          if (!isMine)
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.orange.shade100,
                                              child: userComment.profile != null
                                                  ? ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: "http://10.0.2.2:9000/laravel/${userComment.profile!}",
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Container(
                                                          width: 40,
                                                          height: 40,
                                                          alignment: Alignment.center,
                                                          child: const SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors.orange,
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: Colors.orange.shade100,
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            userComment.name[0].toUpperCase(),
                                                            style: const TextStyle(
                                                              color: Colors.orange,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      userComment.name[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                          if (!isMine) const SizedBox(width: 8),

                                          // Bubble komentar
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isMine
                                                    ? Colors.orange
                                                    : Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(16),
                                                  topRight: const Radius.circular(16),
                                                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                                                  bottomRight: Radius.circular(isMine ? 4 : 16),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange.withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment: isMine
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                                children: [
                                                  if (!isMine)
                                                    Text(
                                                      userComment.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    comment.message,
                                                    style: TextStyle(
                                                      color: isMine
                                                          ? Colors.white
                                                          : Colors.black87,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  if(comment.createAt != null)...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatTime(comment.createAt!),
                                                      style: TextStyle(
                                                        color: isMine
                                                            ? Colors.white70
                                                            : Colors.grey.shade600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ]
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Avatar sendiri
                                          if (isMine) const SizedBox(width: 8),
                                          if (isMine)
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.orange.shade100,
                                              child: widget.currentUser.profile != null
                                                  ? ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: "http://10.0.2.2:9000/laravel/${widget.currentUser.profile!}",
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Container(
                                                          width: 40,
                                                          height: 40,
                                                          alignment: Alignment.center,
                                                          child: const SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors.orange,
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: Colors.orange.shade100,
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            widget.currentUser.name.toUpperCase(),
                                                            style: const TextStyle(
                                                              color: Colors.orange,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      widget.currentUser.name.toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),

                // === INPUT KOMENTAR DENGAN BLUR ===
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    color: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Tulis komentar...",
                                filled: true,
                                fillColor: Colors.orange.withOpacity(0.07),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              if (commentController.text.trim().isEmpty) return;
                              final response = await reactVM.postComment(postVM.currentPost!.id, commentController.text);
                              if(response != null){
                                postVM.onComment(response);
                              }
                              commentController.clear();
                            },
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.orange,
                              child: const Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 7) return "${diff.inDays} hari lalu";

    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }
}