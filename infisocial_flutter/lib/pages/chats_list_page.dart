import 'package:flutter/material.dart';
import 'package:infi_social/pages/chat_page.dart';
import 'package:infi_social/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../services/stream_chat_service.dart';
import 'create_channel_page.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late StreamChannelListController _channelListController;

  @override
  void initState() {
    super.initState();
    _channelListController = StreamChannelListController(
      client: Provider.of<StreamChatService>(context, listen: false).client!,
      filter: Filter.and([
        Filter.equal('type', 'messaging'),
        Filter.in_('members', [
          Provider.of<StreamChatService>(context, listen: false)
              .client!
              .state
              .currentUser!
              .id
        ]),
      ]),
      channelStateSort: const [
        SortOption<ChannelState>('last_message_at', direction: SortOption.DESC)
      ],
      limit: 20,
    );
  }

  @override
  void dispose() {
    _channelListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelListHeader(
        titleBuilder: (context, status, client) {
          if (status == ConnectionStatus.connected) {
            return Text("InfiChat");
          } else {
            return Text("Connecting...");
          }
        },
        onUserAvatarTap: (user) {
          ProfilePage(userId: user.id);
        },
        leading: Container(
          padding: EdgeInsets.all(12),
          child: Image.asset(
            "assets/images/infiSocialLogo.png",
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Icon(Icons.settings),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _channelListController.refresh,
        child: StreamChannelListView(
          controller: _channelListController,
          onChannelTap: (channel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(channel: channel),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateChannelScreen()),
          ).then((_) {
            _channelListController.doInitialLoad();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
