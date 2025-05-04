import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class ConfigService {
  static late String geminiApiKey;
  static late String streamApiKey;
  static late String cloudinaryCloudName;

  static Future<void> fetchApiKey() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval:
            Duration.zero,
      ),
    );

    try {
      await remoteConfig.fetchAndActivate();

      geminiApiKey = remoteConfig.getString('gemini_api_key');
      streamApiKey = remoteConfig.getString('stream_api_key');
      cloudinaryCloudName = remoteConfig.getString('cloudinary_cloud_name');

    } catch (e) {
      debugPrint('Error fetching Remote Config: $e');
    }
  }
}