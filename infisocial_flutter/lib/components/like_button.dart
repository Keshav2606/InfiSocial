import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false;

  void likePost() async {
    if (isLiked) {
      setState(() {
        isLiked = false;
      });
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({
          'likes': FieldValue.arrayRemove([currentUser!.uid])
        });
      } catch (e) {
        debugPrint('Unable to remove like from the post: $e');
      }
    } else {
      setState(() {
        isLiked = true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({
          'likes': FieldValue.arrayUnion([currentUser!.uid])
        });
      } catch (e) {
        debugPrint('Unable to like the post: $e');
      }
    }

    setState(() {});
  }

  void checkIsLiked() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    List postLikes = snapshot.data()!['likes'];

    if (mounted) {
      setState(() {
        isLiked = postLikes.contains(currentUser!.uid);
      });
    }
  }

  @override
  void initState() {
    checkIsLiked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: likePost,
      icon: Icon(
        isLiked ? Icons.thumb_up_sharp : Icons.thumb_up_alt_outlined,
      ),
    );
  }
}
