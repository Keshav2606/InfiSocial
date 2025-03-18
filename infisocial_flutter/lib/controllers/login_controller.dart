import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infi_social/components/bottom_nav.dart';
import 'package:infi_social/controllers/api_service.dart';

class LoginController {
  static login(BuildContext context,
      {required String email, required String password}) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/login");

      final requestBody = {
        "email": email,
        "password": password,
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

        debugPrint("Response Body of Login: $responseBody");

        final box = await Hive.openBox('userData');
        box.put('isLoggedin', true);
        box.put('userId', responseBody['_id']);
        box.put('userFirstName', responseBody['firstName']);
        box.put('userLastName', responseBody['lastName']);
        box.put('username', responseBody['username']);
        box.put('userEmail', responseBody['email']);
        box.put('avatarUrl', responseBody['avatarUrl']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigation(),
          ),
        );
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Login: $responseBody");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${responseBody['error']}'),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  static googleLogin(BuildContext context, String? idToken) async {
    if (idToken == null) return;
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/google-login");

      final requestBody = {
        "idToken": idToken,
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
        debugPrint("Response Body of Google Login: $responseBody");

        final box = await Hive.openBox('userData');
        box.put('isLoggedin', true);
        box.put('userId', responseBody['_id']);
        box.put('userFirstName', responseBody['firstName']);
        box.put('userLastName', responseBody['lastName']);
        box.put('username', responseBody['username']);
        box.put('userEmail', responseBody['email']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigation(),
          ),
        );
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of Google Login: $responseBody");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${responseBody['error']}'),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
