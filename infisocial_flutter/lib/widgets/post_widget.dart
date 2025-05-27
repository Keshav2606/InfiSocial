import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infi_social/pages/profile_page.dart';
import 'package:infi_social/pages/tag_posts_page.dart';
import 'package:infi_social/services/api_service.dart';
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
    this.postOwnerAvatar,
    required this.postOwnerUsername,
  });

  final String postId;
  final List comments;
  final String caption;
  final String postedBy;
  final String? mediaUrl;
  final List<String> likes;
  final String? postOwnerAvatar;
  final String postOwnerUsername;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  Widget _buildCaption(String text, BuildContext context) {
    if (text.isEmpty) {
      return const Text(
        'No caption',
        style: TextStyle(fontSize: 16),
        softWrap: true,
        textAlign: TextAlign.start,
      );
    }

    final hashtagRegex = RegExp(r'#[a-zA-Z][a-zA-Z0-9_]*');
    final usertagRegex = RegExp(r'@[a-zA-Z0-9_]+');
    final List<Map<String, Object>> allMatches = [
      ...hashtagRegex.allMatches(text).map((m) => {
            'text': m.group(0)!,
            'start': m.start,
            'type': 'hashtag',
          }),
      ...usertagRegex.allMatches(text).map((m) => {
            'text': m.group(0)!,
            'start': m.start,
            'type': 'usertag',
          }),
    ]..sort((a, b) => a['start']!.toString().compareTo(b['start']!.toString()));

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (var match in allMatches) {
      final start = match['start']!;
      final matchedText = match['text']!;
      final type = match['type']!;

      // Add text before the match
      if (start as int > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, start)));
      }

      // Add hashtag or usertag
      spans.add(TextSpan(
        text: matchedText as String,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (type == 'hashtag') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagPostsScreen(
                    tag: matchedText.substring(1),
                  ),
                ),
              );
            } else if (type == 'usertag') {
              final response = await http.get(Uri.parse(
                  "${ApiService.baseUrl}/users/search?query=${matchedText.substring(1)}"));

              if (response.statusCode == 200) {
                final user = jsonDecode(response.body)[0];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userId: user["_id"],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Unable to find user."),
                  ),
                );
              }
            }
          },
      ));

      lastEnd = start + matchedText.length;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
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
            child: _buildCaption(widget.caption, context),
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
            ],
          ),
        ],
      ),
    );
  }
}
