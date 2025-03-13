import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/pages/chat_room.dart';
import 'package:infi_social/components/user_profile.dart';
import 'package:infi_social/services/chat/chat_service.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});

  final _chatService = ChatService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: _buildUsersList());
  }

  Widget _buildUsersList() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong.'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No users here.'),
            );
          } else {
            final usersList = snapshot.data;
            usersList!
                .removeWhere((user) => user['user_id'] == currentUser!.uid);
            return ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = usersList[index];
                return InkWell(
                  key: ValueKey(user),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoom(
                          key: ValueKey(user),
                          user: user,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: UserProfileWidget(
                      avatar: user['avatar'],
                    ),
                    title: Text(user['fullname']),
                    subtitle: Text(user['email']),
                  ),
                );
              },
            );
          }
        });
  }
}
