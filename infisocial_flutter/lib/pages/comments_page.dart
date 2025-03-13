import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infi_social/components/comment_widget.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({
    super.key,
    required this.postId,
    required this.comments,
  });

  final String postId;
  final List comments;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final User currentUser = FirebaseAuth.instance.currentUser!;

  void addComment() async {
    String comment = _commentController.text;
    _commentController.clear();

    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('comments').add({
        "postId": widget.postId, // ID of the post this comment belongs to
        "userId": currentUser.uid, // User who created the comment
        "content": comment, // Text content of the comment
        "likes": [], // Array of userIds who liked the comment
        "createdAt": DateTime.now(), // Timestamp for creation
        "updatedAt": DateTime.now(), // Timestamp for last update
      });

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'comments': FieldValue.arrayUnion([docRef.id]),
      });

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
            child: widget.comments.isEmpty
                ? const Center(
                    child: Text('No Comments yet.'),
                  )
                : ListView.separated(
                    itemCount: widget.comments.length,
                    separatorBuilder: (context, _) => const SizedBox(
                      height: 8,
                    ),
                    itemBuilder: (context, index) {
                      String commentId = widget.comments[index];
                      return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .doc(commentId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var comment = snapshot.data!.data();
                              return InkWell(
                                onLongPress: () {
                                  // showDialog(
                                  //   barrierLabel: 'Delete',
                                  //   barrierColor: Colors.grey,
                                  //   barrierDismissible: true,
                                  //   context: context,
                                  //   builder: (context) {
                                  //     return GestureDetector(
                                  //       onTap: () async {
                                  //         await FirebaseFirestore.instance
                                  //             .collection('comments')
                                  //             .doc(commentId)
                                  //             .delete();

                                  //         await FirebaseFirestore.instance
                                  //             .collection('posts')
                                  //             .doc(comment['postId'])
                                  //             .update({
                                  //           'comments': FieldValue.arrayRemove(
                                  //               [commentId])
                                  //         });

                                  //         setState(() {});
                                  //       },
                                  //       child:
                                  //           const Center(child: Text('Delete')),
                                  //     );
                                  //   },
                                  // );
                                },
                                child: CommentWidget(
                                  key: ValueKey(comment),
                                  commentId: commentId,
                                  userId: comment!['userId'],
                                  content: comment['content'],
                                ),
                              );
                            } else {
                              return const Text('');
                            }
                          });
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
