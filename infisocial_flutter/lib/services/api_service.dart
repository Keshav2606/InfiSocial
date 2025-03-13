import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class ConfigService {
  static late String geminiApiKey;

  static Future<void> fetchApiKey() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10), // Set timeout to 10 sec
        minimumFetchInterval:
            Duration.zero, // Forces fetch every time (for testing)
      ),
    );

    try {
      // Fetch and activate the remote config parameters
      await remoteConfig.fetchAndActivate();

      // Retrieve the API URL from the remote config
      geminiApiKey = remoteConfig.getString('gemini_api_key');

    } catch (e) {
      debugPrint('Error fetching Remote Config: $e');
    }
  }
}
