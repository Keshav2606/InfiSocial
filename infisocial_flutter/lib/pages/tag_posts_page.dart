import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:infi_social/models/post_model.dart';
import 'package:infi_social/services/api_service.dart';
import 'package:infi_social/widgets/post_widget.dart';

class TagPostsScreen extends StatelessWidget {
  final String tag;

  const TagPostsScreen({super.key, required this.tag});

  Future<List<PostModel>> fetchPostsByTag() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/posts?tag=$tag'),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<PostModel> posts = [];
      for (var post in responseBody) {
        posts.add(PostModel.fromJson(post));
      }

      return posts;
    }
    throw Exception('Failed to load posts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: FutureBuilder(
        future: fetchPostsByTag(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<PostModel> posts = snapshot.data!;
            return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final PostModel post = posts[index];
                  return PostWidget(
                    postId: post.postId,
                    mediaUrl: post.mediaUrl,
                    caption: post.content,
                    postedBy: post.postedBy,
                    likes: post.likes,
                    comments: post.comments,
                    postOwnerUsername: post.postOwnerUsername,
                    postOwnerAvatar: post.postOwnerAvatar,
                  );
                });
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
