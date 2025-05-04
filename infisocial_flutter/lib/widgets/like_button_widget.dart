import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/controllers/posts_controller.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.postId, required this.postLikes});

  final String postId;
  final List<String> postLikes;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;
  UserModel? currentUser;

  @override
  void initState() {
    currentUser = Provider.of<AuthService>(context, listen: false).user;
    checkIsLiked();

    super.initState();
  }

  void checkIsLiked() async {
    if (mounted) {
      setState(() {
        isLiked = widget.postLikes.contains(currentUser!.id);
      });
    }
  }

  void togglePostLike() async {
    if (isLiked) {
      setState(() {
        isLiked = false;
      });
    } else {
      setState(() {
        isLiked = true;
      });
    }
    try {
      await PostsController.togglePostLike(
        userId: currentUser!.id!,
        postId: widget.postId,
      );
    } catch (e) {
      debugPrint('Unable to remove like from the post: $e');
      if (isLiked) {
        setState(() {
          isLiked = false;
        });
      } else {
        setState(() {
          isLiked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: togglePostLike,
      icon: isLiked
          ? Icon(
              FontAwesomeIcons.solidHeart,
              color: Colors.red,
            )
          : Icon(
              FontAwesomeIcons.heart,
            ),
    );
  }
}
