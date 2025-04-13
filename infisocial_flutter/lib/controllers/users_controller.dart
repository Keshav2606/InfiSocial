import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infi_social/services/api_service.dart';
import 'package:infi_social/models/user_model.dart';

class UsersController {
  static Future<UserModel?> getUserById({
    required String userId,
  }) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/get-user");

      final response = await http.get(
        apiUrl.replace(queryParameters: {"userId": userId}),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body)['user'];
        // debugPrint("Response Body of get user by Id: $responseBody");

        final user = UserModel.fromJson(responseBody);

        return user;
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Signup: $responseBody");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<UserModel?>> getAllUsers() async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/get-all-users");

      final response = await http.get(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body)['users'];
        // debugPrint("Response Body of get all users: $responseBody");

        List<UserModel> users = [];

        for (var data in responseBody) {
          users.add(UserModel.fromJson(data));
        }

        return users;
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Signup: $responseBody");
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<UserModel?> updateUser(
      {required String userId,
      required Map<String, dynamic> updateData}) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/update-user");

      final requestBody = {
        "userId": userId,
        "updateData": updateData,
      };

      final response = await http.put(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = UserModel.fromJson(json.decode(response.body)['user']);

        return user;
      } else {
        debugPrint("Failed to toggle like: ${response.body} ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<bool> followUser({required String userId, required String followUserId}) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/follow");

      final requestBody = {
        "userId": userId,
        "followUserId": followUserId,
      };

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
      return true;

      } else {
        debugPrint("Failed to toggle like: ${response.body} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
