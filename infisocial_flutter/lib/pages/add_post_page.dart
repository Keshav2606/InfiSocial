import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infi_social/utils/functions/pick_image.dart';
import 'package:infi_social/services/storage/storage_service.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  XFile? _image;
  String? _mediaUrl;
  User currentUser = FirebaseAuth.instance.currentUser!;
  TextEditingController captionController = TextEditingController();

  // @override
  // initState() {
  //   super.initState();
  //   pickImage(isCamera: false);
  // }

  Future uploadPost() async {
    _mediaUrl = await uploadOnCloudinary(_image!.path);
    if (_mediaUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to upload image'),
        ),
      );
    } else {
      try {
        await FirebaseFirestore.instance.collection('posts').add({
          "userId": currentUser.uid, // User who created the post
          "content": captionController.text, // Text content of the post
          "mediaUrl": _mediaUrl,
          "mediaType": MediaType.image.name,
          "tags": [], // List of tags associated with the post
          "likes": [], // Array of userIds who liked the post
          "comments": [], // Array of comment IDs related to this post
          "createdAt": DateTime.now(), // Timestamp for creation
          "updatedAt": DateTime.now(), // Timestamp for last update
        });

        _image = null;
        _mediaUrl = null;
        captionController.dispose();

        setState(() {});
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 4, top: 30),
        child: _image == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        _image = await pickImage(isCamera: true);
                        setState(() {});
                      },
                      icon: const Icon(Icons.camera),
                      label: const Text('Camera'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        _image = await pickImage(isCamera: false);
                        setState(() {});
                      },
                      icon: const Icon(Icons.insert_drive_file_outlined),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.file(
                        File(_image!.path),
                        width: double.maxFinite,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: captionController,
                          decoration: const InputDecoration(
                            hintText: 'Add Caption...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: uploadPost,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                              topLeft: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5.5),
                          child: Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
