import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:infi_social/components/user_profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infi_social/utils/functions/get_user_details.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key, required this.user});

  final Map<String, dynamic> user;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late DatabaseReference _messageRef;
  late Stream<DatabaseEvent> _messagesStream;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<dynamic, dynamic>> messages = [];
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String currentUserName = '';

  @override
  void initState() {
    super.initState();
    if (currentUser == null) return;

    getCurrentUserDetails();

    // Generate unique chat room ID
    final chatRoomId = getChatRoomId(currentUser!.uid, widget.user['user_id']);
    _messageRef = FirebaseDatabase.instance.ref().child('messages/$chatRoomId');

    // Listen for new messages
    _messagesStream = _messageRef.onChildAdded;
    _messagesStream.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          messages.add(event.snapshot.value as Map<dynamic, dynamic>);
        });
      }
    });
  }

  Future<void> getCurrentUserDetails() async {
    if (currentUser == null) return;
    final userData = await getUserDetails(currentUser!.uid);
    if (mounted) {
      setState(() {
        currentUserName = userData['username'] ?? 'Unknown';
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageId = _messageRef.push().key!;
    _messageRef.child(messageId).set({
      'text': _messageController.text.trim(),
      'sender': currentUserName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _messageController.clear();
  }

  Widget _buildMessageBubble(String sender, String message) {
    bool isUser = sender == currentUserName;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? "${user1}_$user2" : "${user2}_$user1";
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserProfileWidget(avatar: widget.user['avatar'], size: 30),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user['fullname'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.user['username'],
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(FontAwesomeIcons.ellipsisVertical),
          SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[messages.length - 1 - index];
                return _buildMessageBubble(message['sender'], message['text']);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
