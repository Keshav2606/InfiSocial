import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/components/like_button.dart';
import 'package:infi_social/components/share_button.dart';
import 'package:infi_social/components/user_profile.dart';
import 'package:infi_social/components/comment_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infi_social/utils/functions/get_user_details.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.postId,
    required this.mediaUrl,
    required this.caption,
    required this.postedBy,
    required this.likes,
    required this.comments,
  });

  final String postId;
  final String mediaUrl;
  final String postedBy;
  final String caption;
  final List likes;
  final List comments;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String username = 'username';
  String avatar = '';

  Future getPostOwnerDetails() async {
    var userData = await getUserDetails(widget.postedBy);

    if (mounted) {
      setState(() {
        username = userData['username'];
        avatar = userData['avatar'];
      });
    }
  }

  @override
  void initState() {
    getPostOwnerDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserProfileWidget(avatar: avatar),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Text(username),
                ),
                const Icon(FontAwesomeIcons.ellipsisVertical),
              ],
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          //Caption row.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.caption,
              textAlign: TextAlign.start,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          // Image row.
          GestureDetector(
            onDoubleTap: () {
              // isLiked = true;
            },
            child: Image.network(
              widget.mediaUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * (0.6),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 6,
          ),

          // Bottom row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    LikeButton(
                      postId: widget.postId,
                    ),
                    CommentButton(
                      postId: widget.postId,
                      comments: widget.comments,
                    ),
                    ShareButton(
                      postId: widget.postId,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.save_alt_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
