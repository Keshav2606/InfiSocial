import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:infi_social/pages/start_page.dart';
import 'package:infi_social/firebase_options.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/services/notification_service.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:infi_social/services/stream_chat_service.dart';
import 'package:infi_social/services/remote_config_service.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationServices().showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigService.fetchApiKey();
  CloudinaryObject.fromCloudName(cloudName: ConfigService.cloudinaryCloudName);

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    try {
      NotificationServices().initializeNotification();
      showPushNotificationState();
    } catch (e) {
      debugPrint('$e');
    }
  }

  void showPushNotificationState() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) async {
      debugPrint("FCM-Token: $token");
      final box = await Hive.openBox('userData');
      await box.put('deviceToken', token);
    });

    await FirebaseMessaging.instance.getInitialMessage().then((message) {});

    FirebaseMessaging.onMessage.listen((message) {
      NotificationServices().showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationServices().showNotification(message);
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

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
