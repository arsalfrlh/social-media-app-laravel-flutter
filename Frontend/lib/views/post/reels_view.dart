// 🔥 ULTRA PREMIUM REELS (FIXED + BEAUTIFIED + COMMENT WORKING)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sosmed/viewmodels/reaction_viewmodel.dart';
import 'package:sosmed/viewmodels/post_viewmodel.dart';
import 'package:sosmed/views/message/comment_view.dart';
import 'package:sosmed/views/profile/user_view.dart';
import 'package:video_player/video_player.dart';

class ReelsView extends StatefulWidget {
  const ReelsView({super.key});

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PostViewmodel>(context, listen: false).fetchReels();
    });
  }

  @override
  void dispose() {
    final reelsVM = Provider.of<PostViewmodel>(context, listen: false);
    reelsVM.controller?.removeListener(reelsVM.videoListener);
    reelsVM.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reelsVM = Provider.of<PostViewmodel>(context);
    final reactVM = Provider.of<ReactionViewmodel>(context);

    if (reelsVM.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: reelsVM.pageController,
        scrollDirection: Axis.vertical,
        itemCount: reelsVM.postList.length,
        onPageChanged: (index) {
          reelsVM.playReels(reelsVM.postList[index]);
        },
        itemBuilder: (context, index) {
          final post = reelsVM.postList[index];

          return Stack(
            children: [
              /// 🎬 VIDEO + GESTURE
              Positioned.fill(
                child: reelsVM.controller != null && reelsVM.isInitialize
                    ? GestureDetector(
                        onTap: () {
                          if (reelsVM.controller!.value.isPlaying) {
                            reelsVM.controller!.pause();
                            setState(() => isPlaying = false);
                          } else {
                            reelsVM.controller!.play();
                            setState(() => isPlaying = true);
                          }
                        },
                        onDoubleTap: () async {
                          final res = await reactVM.postReaction(post.id);
                          if (res != null) reelsVM.onReaction(res, index);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(reelsVM.controller!),

                            /// ▶ PLAY ICON
                            if (!isPlaying)
                              const Icon(Icons.play_arrow,
                                  size: 80, color: Colors.white70),
                          ],
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),

              /// 🌈 PREMIUM CINEMATIC GRADIENT
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              /// 🔝 PREMIUM GLASS HEADER
              Positioned(
                top: 20,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.play_circle_fill,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            "Reels",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      /// CAMERA BUTTON (FLOATING STYLE)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade700,
                              Colors.orange.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),

              /// ❤️ ACTION BUTTONS (FIXED COMMENT)
              Positioned(
                right: 12,
                bottom: 120,
                child: Column(
                  children: [
                    _action(Icons.favorite, post.likeCount.toString(),
                        post.liked ? Colors.red : Colors.white, () async {
                      final res = await reactVM.postReaction(post.id);
                      if (res != null) reelsVM.onReaction(res, index);
                    }),

                    _action(Icons.comment,
                        post.commentCount.toString(), Colors.white, () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => CommentView(
                          currentUser: reelsVM.currentUser!,
                          postId: post.id,
                          onClose: () => Navigator.pop(ctx),
                        ),
                      );
                    }),

                    _action(Icons.share, "Share", Colors.white, () {}),

                    const SizedBox(height: 12),

                    /// PROFILE
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserView(userId: post.user!.id)));
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: post.user?.profile != null
                            ? NetworkImage(
                                "http://10.0.2.2:9000/laravel/${post.user!.profile}")
                            : null,
                        child: post.user?.profile == null
                        ? Icon(Icons.person, size: 20,)
                        : null,
                      ),
                    )
                  ],
                ),
              ),

              /// 📄 PREMIUM INFO (GLASS + MODERN)
              Positioned(
                left: 16,
                right: 80,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.35),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 👤 USER + FOLLOW
                      Row(
                        children: [
                          /// USERNAME
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.person,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  post.user!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// FOLLOW BUTTON (PREMIUM)
                          if (post.user?.id != reelsVM.currentUser?.id)
                            GestureDetector(
                              onTap: () async {
                                final res =
                                    await reactVM.followingUser(post.user!.id);
                                if (res != null) {
                                  reelsVM.onFollowed(res, post.user!);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: post.user!.followed
                                      ? LinearGradient(
                                          colors: [
                                            Colors.grey.shade600,
                                            Colors.grey.shade400,
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.orange.shade700,
                                            Colors.orange.shade400,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    if (!post.user!.followed)
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                  ],
                                ),
                                child: Text(
                                  post.user!.followed ? "Following" : "Follow",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// 📝 CAPTION
                      if (post.caption.isNotEmpty)
                        Text(
                          post.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),

                      const SizedBox(height: 8),

                      /// 📅 DATE
                      if (post.createAt != null)
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat("dd MMM yyyy")
                                  .format(post.createAt!),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _action(
      IconData icon, String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
          ),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 12))
        ],
      ),
    );
  }
}
