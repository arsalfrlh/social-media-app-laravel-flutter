import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosmed/models/post.dart';
import 'package:sosmed/viewmodels/reaction_viewmodel.dart';
import 'package:sosmed/viewmodels/user_viewmodel.dart';
import 'package:sosmed/views/message/message_view.dart';
import 'package:sosmed/views/post/show_post_view.dart';
import 'package:sosmed/views/post/show_reels_view.dart';

class UserView extends StatefulWidget {
  const UserView({required this.userId});
  final int userId;

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int lastIndex = 0; // ✅ pindahkan ke sini
  String page = "post";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == lastIndex) return;

      lastIndex = _tabController.index;
      if(lastIndex == 1){
        page = "reels";
      }

      final userVM = Provider.of<UserViewmodel>(context, listen: false);

      if (_tabController.index == 0) {
        userVM.showUser(widget.userId, "post");
      } else {
        userVM.showUser(widget.userId, "reels");
      }
    });

    Future.microtask(() {
      final userVM = Provider.of<UserViewmodel>(context, listen: false);
      userVM.showUser(widget.userId, "post");
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewmodel>(context);
    final reactVM = Provider.of<ReactionViewmodel>(context);
    final user = userVM.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: user == null || userVM.mainUser == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                /// ===== BEAUTIFUL HEADER =====
                SliverAppBar(
                  expandedHeight: 170,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade700, Colors.orange.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                        /// decorative blur circle
                        Positioned(
                          top: -40,
                          right: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [

                              /// 🔥 PROFILE (GLOW + RING)
                              Hero(
                                tag: "profile-pic",
                                child: Container(
                                  padding: const EdgeInsets.all(4),
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
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: ProfilePic(image: user.profile),
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// 👤 NAME (PREMIUM TEXT)
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                              ),

                              const SizedBox(height: 3),

                              /// 🧊 BIO / USERNAME (GLASS STYLE)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                margin: const EdgeInsets.symmetric(horizontal: 40),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                child: Text("@${user.name.toLowerCase().replaceAll(" ", "_")}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // actions: [
                  //   IconButton(
                  //     icon: const Icon(Icons.logout, color: Colors.white),
                  //     onPressed: () {},
                  //   )
                  // ],
                ),

                /// ===== GLASS STATS CARD =====
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade50.withOpacity(0.9),
                              Colors.white.withOpacity(0.95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),

                          /// 🔥 BORDER HALUS (BIAR KELIHATAN MAHAL)
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.15),
                            width: 1,
                          ),

                          /// 🔥 SHADOW LEBIH HIDUP
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildStat(lastIndex == 0 ? "Posts" : "Reels", user.postList.length),
                            buildStat("Followers", user.followersCount),
                            buildStat("Following", user.followingCount),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(height: 10,),
                ),

                /// ===== BIO + BUTTON =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        if(user.id != userVM.mainUser?.id)...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildActionButton(Icons.favorite, user.followed ? "Unfollow" : "Follow", ()async{
                                final response = await reactVM.followingUser(user.id);
                                if(response != null){
                                  userVM.onFollowed(response);
                                }
                              }),
                              const SizedBox(width: 12),
                              buildActionButton(Icons.message, "Message", () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => MessageView(sender: userVM.mainUser!, receiver: user)))),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),

                /// ===== TAB BAR =====
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFFFF7643),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on)),
                        Tab(icon: Icon(Icons.video_collection)),
                      ],
                    ),
                  ),
                ),

                /// ===== GRID =====
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PostCard(
                        post: user.postList[index],
                        onPress: () {
                          if(lastIndex == 1){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowReelsView(userId: user.id, selectedPage: index, page: page)));
                          }else{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostView(userId: user.id, selectedPage: index, page: page)));
                          }
                        },
                      ),
                      childCount: user.postList.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget buildStat(String title, int value) {
    return Column(
      children: [
        Text(value.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey[600]))
      ],
    );
  }

  Widget buildActionButton(IconData icon, String label, VoidCallback onPress) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key, this.image});
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
          )
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: image != null
              ? CachedNetworkImage(
                  imageUrl: "http://10.0.2.2:9000/laravel/$image",
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                )
              : const Icon(Icons.person, size: 60),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onPress});

  final Post post;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Hero(
        tag: "post-${post.id}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: post.type == "video"
                  ? "http://10.0.2.2:9000/laravel/${post.postVideo?.thumbnailPath}"
                  : "http://10.0.2.2:9000/laravel/${post.postImage?[0].imagePath}",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: Row(
                  children: [
                    const Icon(Icons.favorite,
                        color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(post.likeCount.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
