import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infi_social/controllers/api_service.dart';

class GetUserByIdController {
  static Future<Map<String, dynamic>?> getUserById({
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
        debugPrint("Response Body of get user by Id: $responseBody");

        return responseBody;
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
