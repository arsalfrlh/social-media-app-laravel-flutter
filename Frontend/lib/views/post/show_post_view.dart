import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sosmed/models/post.dart';
import 'package:sosmed/models/user.dart';
import 'package:sosmed/viewmodels/reaction_viewmodel.dart';
import 'package:sosmed/viewmodels/post_viewmodel.dart';
import 'package:sosmed/views/message/comment_view.dart';
import 'package:sosmed/views/profile/user_view.dart';

class ShowPostView extends StatefulWidget {
  const ShowPostView({required this.userId, required this.selectedPage, required this.page});
  final int userId, selectedPage;
  final String page;

  @override
  State<ShowPostView> createState() => _ShowPostViewState();
}

class _ShowPostViewState extends State<ShowPostView> {
  final ScrollController _scrollController = ScrollController(); //tambahkan controller untk selectedPage

  @override
  void initState() {
    super.initState();
    Future.microtask(()async{
      final vm = Provider.of<PostViewmodel>(context, listen: false);
      await vm.showAllPostUser(widget.userId, widget.page, widget.selectedPage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.selectedPage);
      });
    });
  }

  void _scrollToIndex(int index) {
    double itemHeight = 450; // kira-kira tinggi card kamu

    _scrollController.jumpTo( //state context langsung ke postingan yg dipilih
      index * itemHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postVM = Provider.of<PostViewmodel>(context);
    final reactVM = Provider.of<ReactionViewmodel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Postingan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => postVM.showAllPostUser(widget.userId, widget.page, widget.selectedPage),
        child: postVM.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Postingan
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController, //controller ini agar menampilkan langsung ke postingan yg di pilih dengan selectedPage sebelumnya
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: postVM.postList.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PostImageCard(
                            postingan: postVM.postList[index],
                            currentUser: postVM.currentUser!,
                            like: () async {
                              final response = await reactVM.postReaction(postVM.postList[index].id);
                              if(response != null){
                                postVM.onReaction(response, index);
                              }
                            },
                            onFollow: () async{
                              final response = await reactVM.followingUser(postVM.postList[index].user!.id);
                              if(response != null){
                                postVM.onFollowed(response, postVM.postList[index].user!);
                              }
                            },
                            comment: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) {
                                  return CommentView(
                                    currentUser: postVM.currentUser!,
                                    postId: postVM.postList[index].id,
                                    onClose: () => Navigator.of(ctx).pop(),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class PostImageCard extends StatefulWidget {
  final Post postingan;
  final User currentUser;

  const PostImageCard({
    super.key,
    required this.postingan,
    required this.like,
    required this.comment,
    required this.onFollow,
    required this.currentUser
  });

  final VoidCallback like, comment, onFollow;

  @override
  State<PostImageCard> createState() => _PostImageCardState();
}

class _PostImageCardState extends State<PostImageCard> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.postingan.postImage ?? [];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.orange.shade50.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 HEADER
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserView(userId: widget.postingan.user!.id)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
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
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: widget.postingan.user?.profile != null
                                ? CachedNetworkImageProvider(
                                    "http://10.0.2.2:9000/laravel/${widget.postingan.user!.profile}")
                                : null,
                            child: widget.postingan.user?.profile == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.postingan.user!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          Text(
                            "${widget.postingan.createAt?.toLocal()}".split('.')[0],
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if(widget.currentUser.id != widget.postingan.user?.id)
                    GestureDetector(
                      onTap: widget.onFollow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: widget.postingan.user!.followed
                              ? LinearGradient(
                                  colors: [Colors.grey.shade400, Colors.grey.shade300],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.orange.shade700,
                                    Colors.orange.shade400,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: widget.postingan.user!.followed
                                  ? Colors.grey.withOpacity(0.4)
                                  : Colors.orange.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.postingan.user!.followed ? "Unfollow" : "Follow",
                          style: TextStyle(
                            color: widget.postingan.user!.followed
                                ? Colors.black87
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              /// 🔥 IMAGE SLIDER
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) {
                        setState(() {
                          currentIndex = i;
                        });
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl:
                              "http://10.0.2.2:9000/laravel/${images[index].imagePath}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),

                  /// 🔥 DOT INDICATOR
                  if (images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: currentIndex == index ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: currentIndex == index
                                  ? LinearGradient(
                                      colors: [
                                        Colors.orange.shade700,
                                        Colors.orange.shade400,
                                      ],
                                    )
                                  : null,
                              color: currentIndex == index
                                  ? null
                                  : Colors.white70,
                            ),
                          );
                        }),
                      ),
                    ),

                  /// 🔥 GRADIENT OVERLAY (BIAR CAPTION KEREN)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// 🔥 CAPTION
              if (widget.postingan.caption != null &&
                  widget.postingan.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.postingan.caption!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[900],
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

              /// 🔥 ACTIONS (LIKE + COMMENT)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// LIKE
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.like,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.postingan.liked
                                  ? LinearGradient(
                                      colors: [
                                        Colors.orange.shade700,
                                        Colors.orange.shade400,
                                      ],
                                    )
                                  : null,
                              color: widget.postingan.liked
                                  ? null
                                  : Colors.grey.shade200,
                              boxShadow: widget.postingan.liked
                                  ? [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.5),
                                        blurRadius: 10,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              widget.postingan.liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.postingan.liked
                                  ? Colors.white
                                  : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${widget.postingan.likeCount}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    /// COMMENT
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.comment,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade200,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${widget.postingan.commentCount}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const searchIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M11.1667 17C7.945 17 5.33333 14.3883 5.33333 11.1667C5.33333 7.94502 7.945 5.33334 11.1667 5.33334C14.3883 5.33334 17 7.94502 17 11.1667C17 12.6897 16.4163 14.0764 15.4605 15.1153L18.4226 18.0774C18.748 18.4029 18.748 18.9305 18.4226 19.2559C18.0971 19.5814 17.5695 19.5814 17.2441 19.2559L14.1616 16.1735C13.2862 16.6983 12.2617 17 11.1667 17ZM11.1667 15.3333C13.4678 15.3333 15.3333 13.4679 15.3333 11.1667C15.3333 8.86549 13.4678 7.00001 11.1667 7.00001C8.86547 7.00001 6.99999 8.86549 6.99999 11.1667C6.99999 13.4679 8.86547 15.3333 11.1667 15.3333Z" fill="#010F07"/>
</svg>
''';

const heartIcon =
    '''<svg width="22" height="20" viewBox="0 0 22 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.1585 10.6702L11.2942 18.6186C11.1323 18.7822 10.8687 18.7822 10.7058 18.6186L2.84145 10.6702C1.81197 9.62861 1.2443 8.24408 1.2443 6.77039C1.2443 5.29671 1.81197 3.91218 2.84145 2.87063C3.90622 1.79552 5.30308 1.25744 6.70098 1.25744C8.09887 1.25744 9.49573 1.79552 10.5605 2.87063C10.8033 3.11607 11.1967 3.11607 11.4405 2.87063C13.568 0.720415 17.03 0.720415 19.1585 2.87063C20.188 3.91113 20.7557 5.29566 20.7557 6.77039C20.7557 8.24408 20.188 9.62966 19.1585 10.6702ZM20.0386 1.98013C17.5687 -0.516223 13.6313 -0.652578 11.0005 1.57316C8.36973 -0.652578 4.43342 -0.516223 1.96245 1.98013C0.696354 3.25977 0 4.96001 0 6.77039C0 8.57972 0.696354 10.281 1.96245 11.5607L9.82678 19.5091C10.1495 19.8364 10.575 20 11.0005 20C11.426 20 11.8505 19.8364 12.1743 19.5091L20.0386 11.5607C21.3036 10.2821 22 8.58077 22 6.77039C22 4.96001 21.3036 3.25872 20.0386 1.98013Z" fill="#B6B6B6"/>
</svg>''';

const chatIcon =
    '''<svg width="22" height="18" viewBox="0 0 22 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M18.4524 16.6669C18.4524 17.403 17.8608 18 17.1302 18C16.3985 18 15.807 17.403 15.807 16.6669C15.807 15.9308 16.3985 15.3337 17.1302 15.3337C17.8608 15.3337 18.4524 15.9308 18.4524 16.6669ZM11.9556 16.6669C11.9556 17.403 11.3631 18 10.6324 18C9.90181 18 9.30921 17.403 9.30921 16.6669C9.30921 15.9308 9.90181 15.3337 10.6324 15.3337C11.3631 15.3337 11.9556 15.9308 11.9556 16.6669ZM20.7325 5.7508L18.9547 11.0865C18.6413 12.0275 17.7685 12.6591 16.7846 12.6591H10.512C9.53753 12.6591 8.66784 12.0369 8.34923 11.1095L6.30162 5.17154H20.3194C20.4616 5.17154 20.5903 5.23741 20.6733 5.35347C20.7563 5.47058 20.7771 5.61487 20.7325 5.7508ZM21.6831 4.62051C21.3697 4.18031 20.858 3.91682 20.3194 3.91682H5.86885L5.0002 1.40529C4.70961 0.564624 3.92087 0 3.03769 0H0.621652C0.278135 0 0 0.281266 0 0.62736C0 0.974499 0.278135 1.25472 0.621652 1.25472H3.03769C3.39158 1.25472 3.70812 1.48161 3.82435 1.8183L4.83311 4.73657C4.83622 4.74598 4.83934 4.75434 4.84245 4.76375L7.17339 11.5215C7.66531 12.9518 9.00721 13.9138 10.512 13.9138H16.7846C18.304 13.9138 19.6511 12.9383 20.1347 11.4859L21.9135 6.14917C22.0847 5.63369 21.9986 5.06175 21.6831 4.62051Z" fill="#7C7C7C"/>
</svg>''';