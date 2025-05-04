import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:infi_social/widgets/user_profile_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/api_service.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/services/remote_config_service.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  UserModel? currentUser;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = ConfigService.geminiApiKey;
  bool _isLoading = false;
  List<dynamic> _conversations = [];
  String? _activeConversationId;

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<AuthService>(context, listen: false).user;
    _fetchConversations();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    if (currentUser == null) return;
    try {
      setState(() => _isLoading = true);
      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/chatbot/conversations?userId=${currentUser!.id}'),
      );
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        setState(() {
          _conversations = jsonDecode(response.body);
        });
      } else {
        _showErrorSnackBar("Failed to load conversations");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Error fetching conversations: ${e.toString()}");
      debugPrint("Error fetching conversations: $e");
    }
  }

  Future<void> _loadMessages(String conversationId) async {
    if (currentUser == null) return;
    try {
      setState(() => _isLoading = true);

      final apiUrl = Uri.parse("${ApiService.baseUrl}/chatbot/messages");
      final response = await http.get(
        apiUrl.replace(queryParameters: {
          "userId": currentUser!.id!,
          "conversationId": conversationId
        }),
      );
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Conversation data: $data");
        setState(() {
          _activeConversationId = conversationId;
          _messages.clear();
          _messages.addAll(
            (data as List).map<Map<String, String>>((msg) => {
                  'sender': msg['sender'].toString(),
                  'message': msg['message'].toString(),
                  'timestamp':
                      DateTime.parse(msg['timestamp']).toLocal().toString(),
                }),
          );
        });
        _scrollToBottom();
      } else {
        _showErrorSnackBar("Failed to load messages");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Error loading messages: ${e.toString()}");
      debugPrint("Error loading messages: $e");
    }
  }

  void _startNewConversation() {
    setState(() {
      _activeConversationId = null;
      _messages.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || currentUser == null) return;

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': userMessage,
        'timestamp': DateTime.now().toIso8601String()
      });
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final newConvoId = await _saveMessageToDB('user', userMessage);
      if (_activeConversationId == null && newConvoId != null) {
        setState(() {
          _activeConversationId = newConvoId;
        });
        _fetchConversations();
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      try {
        final prompt =
            "You are InfiBot, a helpful AI assistant. Respond in a conversational, friendly manner. Your responses should be concise but informative. You can use markdown for formatting.\n\nUser message: $userMessage";
        final response = await model.generateContent([Content.text(prompt)]);
        final botMessage = response.text ?? "No response received.";

        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': botMessage,
            'timestamp': DateTime.now().toIso8601String()
          });
          _isLoading = false;
        });
        _scrollToBottom();

        await _saveMessageToDB('bot', botMessage);
      } catch (e) {
        final errorText =
            'I encountered a problem processing your request. Please try again.';
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': errorText,
            'timestamp': DateTime.now().toIso8601String()
          });
          _isLoading = false;
        });
        await _saveMessageToDB('bot', errorText);
        debugPrint("AI error: ${e.toString()}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Failed to send message");
      debugPrint("Send message error: ${e.toString()}");
    }
  }

  Future<String?> _saveMessageToDB(String sender, String message) async {
    if (currentUser == null) return null;

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/chatbot/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': currentUser!.id,
          'sender': sender,
          'message': message,
          'conversationId': _activeConversationId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (_activeConversationId == null && data['conversationId'] != null) {
          return data['conversationId'];
        }
        return _activeConversationId;
      } else {
        _showErrorSnackBar("Failed to save message");
      }
    } catch (e) {
      _showErrorSnackBar("Network error");
      debugPrint("Failed to save message: ${e.toString()}");
    }

    return null;
  }

  Widget _buildMessageBubble(String sender, String message, String? timestamp) {
    final isUser = sender == 'user';
    final DateTime? messageTime =
        timestamp != null ? DateTime.tryParse(timestamp) : null;
    final String timeString =
        messageTime != null ? DateFormat('h:mm a').format(messageTime) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF0D47A1),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF42A5F5)
                        : const Color(0xFF263238),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        )
                      : MarkdownBody(
                          data: message,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            h1: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            h2: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            code: const TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.black38,
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timeString,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: const Color(0xFF1976D2),
              child: currentUser!.avatarUrl != null
                  ? UserProfileWidget(
                      userId: currentUser!.id!,
                      avatar: currentUser!.avatarUrl!,
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.smart_toy,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to InfiBot!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'I can help answer questions, provide information, or just chat. What would you like to talk about today?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller.text = "Tell me about yourself";
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1976D2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Start conversation"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(dynamic convo, int index) {
    final convoId = convo['_id'];
    final isActive = _activeConversationId == convoId;
    final dateTime = DateTime.tryParse(convo['startTime'] ?? '');
    final formattedDate = dateTime != null
        ? DateFormat('MMM d, yyyy').format(dateTime)
        : 'Unknown date';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF0D47A1).withValues(alpha: 0.4)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.7),
          child: Text(
            '${_conversations.length - index}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          "Conversation ${_conversations.length - index}",
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade300,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.grey.shade300 : Colors.grey.shade500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _loadMessages(convoId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "InfiBot",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _startNewConversation();
              Navigator.pop(context);
            },
            tooltip: "New Conversation",
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A2E),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.smart_toy,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "InfiBot",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${currentUser?.username ?? 'User'}'s Conversations",
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
              ),
              title: const Text(
                "New Conversation",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                _startNewConversation();
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: _isLoading && _conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _conversations.isEmpty
                      ? Center(
                          child: Text(
                            "No conversations yet",
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            return _buildConversationTile(
                                _conversations[index], index);
                          },
                        ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1B)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeMessage()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(
                          message['sender']!,
                          message['message']!,
                          message['timestamp'],
                        );
                      },
                    ),
            ),
            if (_isLoading && _messages.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF42A5F5),
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A40),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextFormField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Message InfiBot...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onEditingComplete: _controller.text.trim().isNotEmpty
                            ? _sendMessage
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _controller.text.trim().isNotEmpty
                          ? _sendMessage
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
