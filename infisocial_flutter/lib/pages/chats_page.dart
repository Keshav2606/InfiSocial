import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: Center());
  }

  
}
