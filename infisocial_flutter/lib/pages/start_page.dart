import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infi_social/pages/main_page.dart';
import 'package:infi_social/pages/login_page.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/services/stream_chat_service.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthState());
  }

  Future<void> _checkAuthState() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final streamChatService =
        Provider.of<StreamChatService>(context, listen: false);

    // Wait until AuthService finishes loading
    while (authService.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (authService.isLoggedIn) {
      final user = authService.user!;

      try {
        // Connect to Stream Chat
        await streamChatService.connectUser(
          user.id!,
          user.username,
          user.avatarUrl,
        );
        
      } catch (e) {
        debugPrint("Stream Chat Connection Failed: $e");
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainPage()),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color.fromARGB(255, 1, 81, 146),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/infiSocialLogo.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              RichText(
                textScaler: TextScaler.linear(3),
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Infi",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(
                      text: "Social",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
