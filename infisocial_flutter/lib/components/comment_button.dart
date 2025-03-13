import 'package:flutter/material.dart';
import 'package:infi_social/pages/comments_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentButton extends StatefulWidget {
  const CommentButton({
    super.key,
    required this.postId,
    required this.comments,
  });

  final String postId;
  final List comments;

  @override
  State<CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<CommentButton> {
  void _openModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) {
        return CommentsPage(
          postId: widget.postId,
          comments: widget.comments,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openModalBottomSheet,
      icon: const Icon(FontAwesomeIcons.comment),
    );
  }
}
