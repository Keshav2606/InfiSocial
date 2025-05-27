import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:infi_social/controllers/users_controller.dart';
import 'package:infi_social/models/post_model.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/pages/edit_profile_page.dart';
import 'package:infi_social/pages/menu_page.dart';
import 'package:infi_social/services/auth_service.dart';
// import 'package:infi_social/utils/functions/pick_image.dart';
// import 'package:infi_social/services/storage_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  UserModel? currentUser;
  // XFile? _image;
  String? avatarUrl;
  bool isFollowing = false;
  List<PostModel> userPosts = [];

  @override
  void initState() {
    currentUser = Provider.of<AuthService>(context, listen: false).user;
    getUserDetails();
    getUserPosts();
    super.initState();
  }

  void getUserDetails() async {
    final _user = await UsersController.getUserById(userId: widget.userId);

    setState(() {
      user = _user;
    });

    if (user!.followers.contains(currentUser!.id)) {
      setState(() {
        isFollowing = true;
      });
    }
  }

  void getUserPosts() async {
    try {
      final _userPosts = await PostsController.getUserPosts(user!.id!);

      setState(() {
        userPosts = _userPosts.where((post) => post.mediaUrl != '').toList();
      });

      debugPrint(userPosts.toString());
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    }
  }

  // _openModalBottomSheet(bool isAvatarApplied) {
  //   showModalBottomSheet(
  //     showDragHandle: true,
  //     scrollControlDisabledMaxHeightRatio: 0.3,
  //     context: context,
  //     builder: (context) {
  //       return ListView(
  //         children: isAvatarApplied
  //             ? [
  //                 GestureDetector(
  //                   onTap: () async {
  //                     _image = await pickImage(isCamera: false);
  //                     avatarUrl = await uploadOnCloudinary(_image!.path);
  //                     await addAvatar(avatarUrl!);
  //                     Navigator.pop(context);

  //                     setState(() {});
  //                   },
  //                   child: const ListTile(
  //                     leading: Icon(Icons.photo),
  //                     title: Text('Add New photo from Gallery'),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 6,
  //                 ),
  //                 GestureDetector(
  //                   onTap: () async {
  //                     _image = await pickImage(isCamera: false);
  //                     avatarUrl = await uploadOnCloudinary(_image!.path);
  //                     await addAvatar(avatarUrl!);
  //                     Navigator.pop(context);
  //                     setState(() {});
  //                   },
  //                   child: const ListTile(
  //                     leading: Icon(Icons.camera),
  //                     title: Text('Add New photo from Camera'),
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () async {
  //                     _image = null;
  //                     avatarUrl = null;
  //                     await removeAvatar();
  //                     Navigator.pop(context);
  //                     setState(() {});
  //                   },
  //                   child: const ListTile(
  //                     leading: Icon(Icons.camera),
  //                     title: Text('Remove Photo'),
  //                   ),
  //                 ),
  //               ]
  //             : [
  //                 GestureDetector(
  //                   onTap: () async {
  //                     _image = await pickImage(isCamera: false);
  //                     if (_image == null) return;
  //                     avatarUrl = await uploadOnCloudinary(_image!.path);
  //                     if (avatarUrl == null) return;
  //                     await addAvatar(avatarUrl!);
  //                     Navigator.pop(context);

  //                     setState(() {});
  //                   },
  //                   child: const ListTile(
  //                     leading: Icon(Icons.photo),
  //                     title: Text('Add photo from Gallery'),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 6,
  //                 ),
  //                 GestureDetector(
  //                   onTap: () async {
  //                     _image = await pickImage(isCamera: false);
  //                     avatarUrl = await uploadOnCloudinary(_image!.path);
  //                     await addAvatar(avatarUrl!);
  //                     Navigator.pop(context);
  //                     setState(() {});
  //                   },
  //                   child: const ListTile(
  //                     leading: Icon(Icons.camera),
  //                     title: Text('Add photo from Camera'),
  //                   ),
  //                 ),
  //               ],
  //       );
  //     },
  //   );
  // }

  Future<void> addAvatar(String avatarUrl) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.updateUser(userId: user!.id!, updateData: {
        'avatarUrl': avatarUrl,
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
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.updateUser(userId: user!.id!, updateData: {
        'avatarUrl': null,
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
                  MaterialPageRoute(
                    builder: (context) => const MenuPage(),
                  ),
                );
              },
              icon: const Icon(Icons.menu)),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: RefreshIndicator(
                onRefresh: () {
                  getUserDetails();
                  getUserPosts();
                  return Future.value(true);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // if (user!.id == currentUser!.id) {
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           EditUserProfilePage(),
                                    //     ),
                                    //   );
                                    // } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.black12
                                                .withValues(alpha: 60),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 6),
                                            child: user!.avatarUrl != ''
                                                ? Image.network(
                                                    user!.avatarUrl!)
                                                : const Icon(
                                                    Icons.person,
                                                    size: 100,
                                                  ),
                                          );
                                        });
                                    // }
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: user!.avatarUrl != null &&
                                            user!.avatarUrl != ''
                                        ? ClipOval(
                                            child: Image.network(
                                              user!.avatarUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 50,
                                          ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "${user!.firstName} ${user!.lastName}",
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('@${user!.username}'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          user!.followers.length.toString(),
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
                                        Text(
                                          user!.following.length.toString(),
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
                                SizedBox(
                                  height: 12,
                                ),
                                if (user!.id == currentUser!.id)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const EditUserProfilePage(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: const Text('Edit Profile'),
                                    ),
                                  ),
                                if (user!.id != currentUser!.id)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final bool isSuccess =
                                            await UsersController.followUser(
                                                userId: currentUser!.id!,
                                                followUserId: user!.id!);

                                        if (isSuccess) {
                                          setState(() {
                                            isFollowing = true;
                                          });
                                        } else {
                                          setState(() {
                                            isFollowing = false;
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: isFollowing
                                            ? Colors.black45
                                            : Colors.white,
                                        backgroundColor: isFollowing
                                            ? Colors.blue[100]
                                            : Colors.blue,
                                      ),
                                      child: Text(
                                          isFollowing ? 'Following' : 'Follow'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Posts',
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              userPosts[index].mediaUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
