import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infi_social/pages/tag_posts_page.dart';
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
  // Function to build caption with highlighted hashtags
  Widget _buildCaption(String text) {
    if (text.isEmpty) {
      return const Text(
        'No caption',
        style: TextStyle(fontSize: 16),
        softWrap: true,
        textAlign: TextAlign.start,
      );
    }

    final hashtagRegex = RegExp(r'#[a-zA-Z][a-zA-Z0-9_]*');
    final parts = text.split(hashtagRegex);
    final matches =
        hashtagRegex.allMatches(text).map((m) => m.group(0)).toList();

    List<TextSpan> spans = [];
    int partIndex = 0;

    for (var i = 0; i < parts.length + matches.length; i++) {
      if (i % 2 == 0 && partIndex < parts.length) {
        spans.add(TextSpan(text: parts[partIndex]));
        partIndex++;
      } else if (i % 2 == 1 && (i ~/ 2) < matches.length) {
        spans.add(TextSpan(
          text: matches[i ~/ 2],
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagPostsScreen(
                    tag: matches[i ~/ 2]!.substring(1),
                  ),
                ),
              );
            },
        ));
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      softWrap: true,
      textAlign: TextAlign.start,
    );
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
                UserProfileWidget(
                  userId: widget.postedBy,
                  avatar: widget.postOwnerAvatar ?? '',
                  size: 40,
                ),
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
          // Caption row with hashtag highlighting
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCaption(widget.caption),
          ),
          const SizedBox(
            height: 6,
          ),
          // Image row
          if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty)
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
                  height: MediaQuery.of(context).size.height * 0.6,
                  alignment: Alignment.center,
                ),
              ),
            ),
          // Bottom row
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
