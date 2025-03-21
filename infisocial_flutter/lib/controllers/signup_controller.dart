import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infi_social/services/api_service.dart';
import 'package:infi_social/models/user_model.dart';

class SignUpController {
  static Future<UserModel?> signUp({
    required String firstName,
    String lastName = '',
    required String username,
    required String email,
    required String password,
    required String age,
    required String gender,
  }) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/signup");

      final user = UserModel(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        age: age,
        gender: gender,
      );

      final requestBody = {...user.toJson(), "password": password};

      debugPrint("Request Body for User Signup: $requestBody");

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Signup: $responseBody");

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
}
