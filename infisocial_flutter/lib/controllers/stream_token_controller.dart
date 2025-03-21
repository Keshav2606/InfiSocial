import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:infi_social/services/api_service.dart';

class StreamTokenController {
  static Future<String?> getStreamToken({
    required String userId,
  }) async {
    try {
      final apiUrl = Uri.parse("${ApiService.baseUrl}/users/get-stream-token");

      final response = await http.get(
        apiUrl.replace(queryParameters: {"userId": userId}),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body)['token'];
        debugPrint("Response Body of get stream token: $responseBody");

        return responseBody;
      } else {
        final responseBody = json.decode(response.body);
        debugPrint("Response Body of get stream token: $responseBody");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
