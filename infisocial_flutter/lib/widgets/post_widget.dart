import 'package:flutter/material.dart';
import 'package:infi_social/widgets/like_button_widget.dart';
import 'package:infi_social/widgets/share_button_widget.dart';
import 'package:infi_social/widgets/user_profile_widget.dart';
import 'package:infi_social/widgets/comment_button_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.postId,
    required this.mediaUrl,
    required this.caption,
    required this.postedBy,
    required this.likes,
    required this.comments,
    required this.postOwnerUsername,
    this.postOwnerAvatar,
  });

  final String postId;
  final String? mediaUrl;
  final String postedBy;
  final String caption;
  final List<String> likes;
  final List comments;
  final String postOwnerUsername;
  final String? postOwnerAvatar;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
                UserProfileWidget(
                    userId: widget.postedBy,
                    avatar: widget.postOwnerAvatar ?? '', size: 40),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Text(widget.postOwnerUsername),
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
              softWrap: true,
              textAlign: TextAlign.start,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          // Image row.
          if (widget.mediaUrl != null && widget.mediaUrl != '')
            Container(
              width: double.infinity,
              color: Colors.black12,
              child: GestureDetector(
                onDoubleTap: () {
                  // isLiked = true;
                },
                child: Image.network(
                  widget.mediaUrl!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * (0.6),
                  alignment: Alignment.center,
                ),
              ),
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
                      postLikes: widget.likes,
                    ),
                    CommentButton(
                      postId: widget.postId,
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
