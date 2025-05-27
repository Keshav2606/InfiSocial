import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/api_service.dart';

class SignInController {
  static Future<UserModel?> getCurrentUser(String userId) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/get-user");

      final queryParam = {
        "userId": userId,
      };

      final response = await http.get(
        apiUrl.replace(queryParameters: queryParam),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body)['user'];

        // debugPrint("Response Body of get current user: $responseBody");

        final user = UserModel.fromJson(responseBody);

        return user;
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Login: $responseBody");

        return null;
      }
    } catch (e) {
      debugPrint(e.toString());

      return null;
    }
  }

  static Future<UserModel?> signIn(
      {required String email, required String password}) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/login");

      final box = await Hive.openBox("userData");
      final token = await box.get("deviceToken");

      final requestBody = {
        "email": email,
        "password": password,
        "deviceToken": token,
      };

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body)['user'];

        final user = UserModel.fromJson(responseBody);

        return user;
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Login: $responseBody");

        return null;
      }
    } catch (e) {
      debugPrint(e.toString());

      return null;
    }
  }

  static Future<UserModel?> signInWithGoogle(String? idToken) async {
    if (idToken == null) return null;
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/google-login");

      final box = await Hive.openBox("userData");
      final token = await box.get("deviceToken");

      final requestBody = {
        "idToken": idToken,
        "deviceToken": token,
      };

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body)['user'];

        final user = UserModel.fromJson(responseBody);

        return user;
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Google Login: $responseBody");

        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
