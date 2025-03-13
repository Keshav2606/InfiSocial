import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infi_social/components/post_widget.dart';
import 'package:infi_social/utils/functions/get_user_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String avatar = '';
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    getCurrentUserDetails();
    super.initState();
  }

  Future getCurrentUserDetails() async {
    var userData = await getUserDetails(currentUser!.uid);

    if (mounted) {
      setState(() {
        avatar = userData['avatar'];
      });
    }
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Loading data...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.data!.docs.isNotEmpty) {
            var posts = snapshot.data!.docs;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.separated(
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 6,
                ),
                itemBuilder: (context, index) {
                  return PostWidget(
                    postId: posts[index].id,
                    mediaUrl: posts[index]['mediaUrl'],
                    caption: posts[index]['content'],
                    postedBy: posts[index]['userId'],
                    likes: posts[index]['likes'],
                    comments: posts[index]['comments'],
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
