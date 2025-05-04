import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:infi_social/models/post_model.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/api_service.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/utils/functions/pick_image.dart';
import 'package:infi_social/services/storage_service.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  XFile? _image;
  String? _mediaUrl;
  UserModel? currentUser;
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];
  // bool _showSuggestions = false;
  String _currentQuery = '';
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    currentUser = Provider.of<AuthService>(context, listen: false).user;
    super.initState();
  }

  // Function to build caption preview with highlighted hashtags and tags
  Widget _buildCaptionPreview(String text) {
    if (text.isEmpty) {
      return const Text(
        'Type to see preview',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      );
    }

    final hashtagRegex = RegExp(r'#[a-zA-Z][a-zA-Z0-9_]*');
    final userTagRegex = RegExp(r'@[a-zA-Z0-9_]+');
    final allMatches = [
      ...hashtagRegex
          .allMatches(text)
          .map((m) => {'text': m.group(0)!, 'type': 'hashtag'}),
      ...userTagRegex
          .allMatches(text)
          .map((m) => {'text': m.group(0)!, 'type': 'usertag'}),
    ]..sort((a, b) => a['text']!.compareTo(b['text']!));

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (var match in allMatches) {
      final start = text.indexOf(match['text']!, lastEnd);
      if (start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, start)));
      }
      spans.add(TextSpan(
        text: match['text'],
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastEnd = start + match['text']!.length;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      softWrap: true,
    );
  }

  // Fetch username suggestions
  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        // _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/search?query=$query'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _suggestions = data.cast<Map<String, dynamic>>();
          // _showSuggestions = true;
        });
        _showOverlay();
      } else {
        setState(() {
          _suggestions = [];
          // _showSuggestions = false;
        });
        _removeOverlay();
      }
    } catch (error) {
      setState(() {
        _suggestions = [];
        // _showSuggestions = false;
      });
      _removeOverlay();
    }
  }

  // Show suggestion overlay
  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32, // Match TextField width
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Below TextField
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: _suggestions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No users found'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final user = _suggestions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: user['avatarUrl'] != null
                                ? NetworkImage(user['avatarUrl'])
                                : null,
                            child: user['avatarUrl'] == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          title: Text(
                            user['username'],
                          ),
                          onTap: () {
                            _insertSuggestion(user['username']);
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  // Remove overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Insert selected username into caption
  void _insertSuggestion(String username) {
    final text = _captionController.text;
    final cursorPos = _captionController.selection.baseOffset;
    if (cursorPos < 0) return;

    // Find the start of the current @query
    int start = cursorPos - 1;
    while (start >= 0 && text[start] != ' ' && text[start] != '@') {
      start--;
    }
    if (start < 0 || text[start] != '@') {
      start = cursorPos;
    } else {
      start++; // Skip the @
    }

    final newText =
        text.substring(0, start) + username + text.substring(cursorPos);
    _captionController.text = newText;
    _captionController.selection = TextSelection.collapsed(
      offset: start + username.length,
    );

    setState(() {
      _suggestions = [];
      // _showSuggestions = false;
    });
    _removeOverlay();
  }

  // Upload post
  Future<void> uploadPost() async {
    if (_captionController.text.isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a caption or image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_image != null) {
        _mediaUrl = await uploadOnCloudinary(_image!.path);
        if (_mediaUrl == null) {
          throw Exception('Unable to upload image');
        }
      }

      await PostsController.addPost(
        content: _captionController.text,
        mediaUrl: _mediaUrl,
        mediaType: _mediaUrl != null ? MediaType.image.name : null,
        tags: [], // Backend handles tags and taggedUsers
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created!')),
      );

      setState(() {
        _image = null;
        _mediaUrl = null;
        _captionController.clear();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick image
  Future<void> _pickImage() async {
    final pickedFile = await pickImage(isCamera: false);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  // Remove image
  void _removeImage() {
    setState(() {
      _image = null;
      _mediaUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Post'),
          elevation: 0,
          actions: [
            IconButton(
              icon: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.send),
              onPressed: _isLoading ? null : uploadPost,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: currentUser != null &&
                                  currentUser!.avatarUrl != ''
                              ? ClipOval(
                                  child: Image.network(
                                    currentUser!.avatarUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentUser!.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: TextFormField(
                        controller: _captionController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Write Something...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                        maxLines: 5,
                        onChanged: (value) {
                          final cursorPos =
                              _captionController.selection.baseOffset;
                          if (cursorPos < 0) return;

                          int start = cursorPos - 1;
                          bool isAtSymbol = false;
                          while (start >= 0 && value[start] != ' ') {
                            if (value[start] == '@') {
                              isAtSymbol = true;
                              break;
                            }
                            start--;
                          }

                          if (isAtSymbol && start + 1 < cursorPos) {
                            final query = value.substring(start + 1, cursorPos);
                            if (query != _currentQuery) {
                              _currentQuery = query;
                              _fetchSuggestions(query);
                            }
                          } else {
                            _currentQuery = '';
                            setState(() {
                              _suggestions = [];
                            });
                            _removeOverlay();
                          }

                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Caption preview
                    const Text(
                      'Preview:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildCaptionPreview(_captionController.text),
                    const SizedBox(height: 16),
                    // Image upload and preview
                    _image == null
                        ? OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Pick Image'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_image!.path),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _removeImage,
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                label: const Text(
                                  'Remove Image',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }
}
