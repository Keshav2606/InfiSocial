import 'package:flutter/material.dart';
import 'package:infi_social/widgets/post_widget.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:infi_social/models/post_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late Future<List<PostModel>> posts;

  @override
  void initState() {
    super.initState();

    posts = PostsController.getAllPosts();
  }

  void refreshHomePage() {
    setState(() {
      posts = PostsController.getAllPosts();
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          textScaler: TextScaler.linear(1.8),
          text: TextSpan(
            children: [
              TextSpan(
                text: "Infi",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: "Social",
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: FutureBuilder(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Loading data...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.data!.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                refreshHomePage();
              },
              child: ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 6,
                ),
                itemBuilder: (context, index) {
                  PostModel post = snapshot.data![index];
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
                },
              ),
            );
          } else {
            return const Center(
              child: Text('No data Found'),
            );
          }
        },
      ),
    );
  }
}
