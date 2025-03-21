import 'package:flutter/material.dart';
import 'package:infi_social/services/remote_config_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key});

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = ConfigService.geminiApiKey;

  Future<void> _sendMessage() async {
    String userMessage = _controller.text;
    if (userMessage.isEmpty) return;

    debugPrint('User message: $userMessage');

    setState(() {
      _messages.add({'sender': 'user', 'message': userMessage});
      _controller.clear();
    });

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    try {
      final content = [Content.text(userMessage)];
      final response = await model.generateContent(content);

      String botMessage = response.text!;

      setState(() {
        _messages.add({'sender': 'bot', 'message': botMessage});
      });
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message': 'Something went wrong: ${e.toString()}'
        });
      });
    }
  }

  Widget _buildMessageBubble(String sender, String message) {
    bool isUser = sender == 'user';
    return Align(
      alignment: !isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InfiBot"),
        leading: Container(
          padding: EdgeInsets.all(12),
          child: Image.asset(
            "assets/images/infiSocialLogo.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text('Start conversation with InfiBot'),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(
                          message['sender']!, message['message']!);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _sendMessage();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
