import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:infi_social/pages/start_page.dart';
import 'package:infi_social/firebase_options.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:infi_social/services/stream_chat_service.dart';
import 'package:infi_social/services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigService.fetchApiKey();
  CloudinaryObject.fromCloudName(cloudName: ConfigService.cloudinaryCloudName);

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  final streamChatService = StreamChatService();
  await streamChatService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<StreamChatService>.value(value: streamChatService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final streamChatService = Provider.of<StreamChatService>(context);

    return MaterialApp(
      title: 'InfiSocial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return StreamChat(
          client: streamChatService.client!,
          child: child!,
        );
      },
      home: const StartPage(),
    );
  }
}
