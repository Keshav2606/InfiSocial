import 'package:flutter/material.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:provider/provider.dart';

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

  Future<void> getCurrentUser() async {
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);

    setState(() {
      currentUser = authService.user;
    });

    debugPrint("Current User after parsing: $currentUser");
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

  void checkIsLiked() async {
    if (mounted) {
      setState(() {
        isLiked = widget.postLikes.contains(currentUser!.id);
      });
    }
  }

  @override
  void initState() {
    getCurrentUser();

    Future.delayed(Duration(milliseconds: 1200), () {
      checkIsLiked();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: togglePostLike,
      icon: Icon(
        isLiked ? Icons.thumb_up_sharp : Icons.thumb_up_alt_outlined,
      ),
    );
  }
}
