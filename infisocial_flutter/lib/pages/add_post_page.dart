import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:infi_social/models/post_model.dart';
import 'package:infi_social/utils/functions/pick_image.dart';
import 'package:infi_social/services/storage_service.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  XFile? _image;
  String? _mediaUrl;
  TextEditingController captionController = TextEditingController();

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
        await PostsController.addPost(
            content: captionController.text,
            mediaUrl: _mediaUrl,
            mediaType: MediaType.image.name,
            tags: [""]);

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
      appBar: AppBar(
        title: const Text('Add Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: uploadPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            _image == null
                ? ElevatedButton.icon(
                    onPressed: () async {
                      final pickedFile = await pickImage(isCamera: false);
                      setState(() {
                        _image = pickedFile;
                      });
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  )
                : Image.file(File(_image!.path)),
          ],
        ),
      ),
    );
  }
}
