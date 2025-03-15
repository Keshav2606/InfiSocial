import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:infi_social/firebase_options.dart';
import 'package:infi_social/pages/start_page.dart';
import 'package:infi_social/services/api_service.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigService.fetchApiKey();
  CloudinaryObject.fromCloudName(cloudName: 'dzr6atmmi');

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfiSocial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const StartPage(),
    );
  }
}
