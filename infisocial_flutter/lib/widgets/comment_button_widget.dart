import 'package:flutter/material.dart';
import 'package:infi_social/pages/comments_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentButton extends StatefulWidget {
  const CommentButton({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<CommentButton> {
  void _openModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isDismissible: true,
      backgroundColor: Colors.black,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return CommentsPage(
          postId: widget.postId,
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
