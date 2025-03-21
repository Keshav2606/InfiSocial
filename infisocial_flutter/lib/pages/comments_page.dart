import 'package:flutter/material.dart';
import 'package:infi_social/widgets/comment_widget.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:infi_social/models/comment_model.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:provider/provider.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  UserModel? currentUser;

  late Future<List<CommentModel>> comments;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    comments = PostsController.getAllComments(widget.postId);
  }

  Future<void> getCurrentUser() async {
    final AuthService authService =
        Provider.of<AuthService>(context, listen: false);

    setState(() {
      currentUser = authService.user;
    });

    debugPrint("Current User after parsing: $currentUser");
  }

  void addComment() async {
    String comment = _commentController.text;
    _commentController.clear();

    try {
      await PostsController.addComment(
        userId: currentUser!.id!,
        postId: widget.postId,
        content: comment,
      );

      setState(() {});
    } catch (e) {
      debugPrint('Unable to add comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'Comments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Expanded(
            child: FutureBuilder(
              future: comments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text("Loading comments..."),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load comments'),
                  );
                } else if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No comments yet."),
                  );
                } else {
                  final comments = snapshot.data as List<CommentModel>;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return CommentWidget(
                        comment: comment,
                      );
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              hintText: 'Add a comment',
              suffixIcon: IconButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    addComment();
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.send),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )
        ],
      ),
    );
  }
}
