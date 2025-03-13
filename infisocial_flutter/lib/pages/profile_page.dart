import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/pages/menu_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infi_social/utils/functions/pick_image.dart';
import 'package:infi_social/services/storage/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  XFile? _image;
  String? avatarUrl;
  List userPosts = [];

  @override
  void initState() {
    fetchUserPosts();
    super.initState();
  }

  void fetchUserPosts() async {
    try {
      // Fetch all documents from the 'posts' collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      List<Map<String, dynamic>> postsData = [];

      // Extract data from all documents
      for (var doc in querySnapshot.docs) {
        if (doc.data().containsKey('userId')) {
          postsData.add(doc.data());
        }
      }

      // Filter posts for the current user
      List<Map<String, dynamic>> userPostsData = postsData
          .where((post) => post['userId'] == currentUser!.uid)
          .toList();

      // Update UI
      setState(() {
        userPosts = userPostsData;
      });

      debugPrint(userPosts.toString());
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    }
  }

  _openModalBottomSheet(bool isAvatarApplied) {
    showModalBottomSheet(
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: 0.3,
      context: context,
      builder: (context) {
        return ListView(
          children: isAvatarApplied
              ? [
                  GestureDetector(
                    onTap: () async {
                      _image = await pickImage(isCamera: false);
                      avatarUrl = await uploadOnCloudinary(_image!.path);
                      await addAvatar(avatarUrl!);
                      Navigator.pop(context);

                      setState(() {});
                    },
                    child: const ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('Add New photo from Gallery'),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  GestureDetector(
                    onTap: () async {
                      _image = await pickImage(isCamera: false);
                      avatarUrl = await uploadOnCloudinary(_image!.path);
                      await addAvatar(avatarUrl!);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Add New photo from Camera'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      _image = null;
                      avatarUrl = null;
                      await removeAvatar();
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Remove Photo'),
                    ),
                  ),
                ]
              : [
                  GestureDetector(
                    onTap: () async {
                      _image = await pickImage(isCamera: false);
                      avatarUrl = await uploadOnCloudinary(_image!.path);
                      await addAvatar(avatarUrl!);
                      Navigator.pop(context);

                      setState(() {});
                    },
                    child: const ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('Add photo from Gallery'),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  GestureDetector(
                    onTap: () async {
                      _image = await pickImage(isCamera: false);
                      avatarUrl = await uploadOnCloudinary(_image!.path);
                      await addAvatar(avatarUrl!);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Add photo from Camera'),
                    ),
                  ),
                ],
        );
      },
    );
  }

  Future<void> addAvatar(String avatarUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'avatar': avatarUrl,
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> removeAvatar() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'avatar': '',
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              icon: const Icon(Icons.menu)),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString()}'),
            );
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            List followers = user!['followers'];
            List following = user['following'];
            return Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _openModalBottomSheet(user['avatar'] != '');
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: user['avatar'] != ''
                                ? ClipOval(
                                    child: Image.network(
                                      user['avatar'],
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          user['fullname'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        Text('@${user['username']}'),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          // User Posts data
                          Text(
                            userPosts.length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          // Users followers data
                          Text(
                            followers.length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Followers',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          // Users following data
                          Text(
                            following.length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Following',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Posts',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        return GridTile(
                          key: ValueKey(userPosts[index]),
                          child: Image.network(
                            userPosts[index]['mediaUrl'],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No data...'),
            );
          }
        },
      ),
    );
  }
}
