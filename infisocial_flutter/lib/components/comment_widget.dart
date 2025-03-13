import 'package:flutter/material.dart';
import 'package:infi_social/components/user_profile.dart';
import 'package:infi_social/utils/functions/get_user_details.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({
    super.key,
    required this.commentId,
    required this.content,
    required this.userId,
  });

  final String commentId;
  final String userId;
  final String content;

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  String username = 'username';
  String avatar = '';

  getCommentUserDetails() async {
    var commentedBy = await getUserDetails(widget.userId);
    if (mounted) {
      setState(() {
        username = commentedBy['username'];
        avatar = commentedBy['avatar'];
      });
    }
  }

  @override
  void initState() {
    getCommentUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Row(
        children: [
          UserProfileWidget(
            avatar: avatar,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
