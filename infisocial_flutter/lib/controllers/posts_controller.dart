import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:infi_social/services/api_service.dart';
import 'package:infi_social/models/comment_model.dart';
import 'package:infi_social/models/post_model.dart';

class PostsController {
  static Future<void> addPost(
      {required String content,
      String? mediaUrl,
      String? mediaType,
      required List<String> tags}) async {
    try {
      final box = await Hive.openBox('userData');
      final user = await box.get('currentUserData');

      final userId = user['_id'];

      final apiUrl = Uri.parse("${ApiService.baseUrl}/posts/add-post");

      final requestBody = {
        "userId": userId,
        "content": content,
        "mediaUrl": mediaUrl,
        "mediaType": mediaType,
        "tags": tags,
      };

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("Post added successfully: ${response.body}");
      } else {
        debugPrint("Failed to add post: ${response.body} ${response.body}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<PostModel>> getAllPosts() async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/posts/get-posts");

      final response = await http.get(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        // body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("Posts fetched successfully: ${response.body}");

        final responseBody = json.decode(response.body)['posts'];

        List<PostModel> formattedData = [];

        for (var data in responseBody) {
          formattedData.add(PostModel.fromJson(data));
        }

        return formattedData;
      } else {
        debugPrint("Failed to fetch posts: ${response.body} ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<PostModel?> getPostById(String postId) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/post");

      final response = await http.get(
        apiUrl.replace(queryParameters: { "postId": postId }),
        headers: {"Content-Type": "application/json"},
        // body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("Posts fetched successfully: ${response.body}");

        final responseBody = json.decode(response.body)['post'];

        PostModel formattedData = PostModel.fromJson(responseBody);

        return formattedData;
      } else {
        debugPrint("Failed to fetch posts: ${response.body} ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/posts/get-user-posts");

      final queryParams = {
        "userId": userId,
      };

      final response = await http.get(
        apiUrl.replace(queryParameters: queryParams),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("User Posts fetched successfully: ${response.body}");

        final responseBody = json.decode(response.body)['posts'];

        List<PostModel> formattedData = [];

        for (var data in responseBody) {
          formattedData.add(PostModel.fromJson(data));
        }

        return formattedData;
      } else {
        debugPrint("Failed to fetch posts: ${response.body} ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<void> togglePostLike({
    required String userId,
    required String postId,
  }) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/posts/toggle-like");

      final requestBody = {
        "userId": userId,
        "postId": postId,
      };

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint(response.body);
      } else {
        debugPrint("Failed to toggle like: ${response.body} ${response.body}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> addComment(
      {required String userId,
      required String postId,
      required String content}) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/posts/add-comment");

      final requestBody = {
        "userId": userId,
        "postId": postId,
        "content": content,
      };

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint(response.body);
      } else {
        debugPrint("Failed to toggle like: ${response.body} ${response.body}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<CommentModel>> getAllComments(String postId) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/posts/get-comments");

      final queryParams = {
        "postId": postId,
      };

      final response = await http.get(
        apiUrl.replace(queryParameters: queryParams),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint("Comments fetched successfully: ${response.body}");

        final responseBody = json.decode(response.body)['comments'];

        List<CommentModel> formattedData = [];

        for (var data in responseBody) {
          formattedData.add(CommentModel.fromJson(data));
        }

        return formattedData;
      } else {
        debugPrint(
            "Failed to fetch comments: ${response.body} ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
