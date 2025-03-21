import 'package:infi_social/controllers/stream_token_controller.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  StreamChatClient? client;

  Future<void> initialize() async {
    client = StreamChatClient(
      'emsasgs8sk4j',
      logLevel: Level.INFO,
    );
  }

  Future<void> connectUser(String userId, String name, String? image) async {
    if (client == null) {
      throw Exception(
          "StreamChatClient is not initialized. Call initialize() first.");
    }

    // Generate a token (Use a real backend token in production)
    final token = await StreamTokenController.getStreamToken(userId: userId);

    await client!.connectUser(
      User(
        id: userId,
        name: name,
        image: image,
      ),
      token.toString(),
    );
  }

  Future<void> disconnectUser() async {
    if (client != null) {
      await client!.disconnectUser();
    }
  }

  Future<Channel> createOneToOneChannel(String userId1, String userId2) async {
    final channel = client!.channel(
      'messaging',
      id: '${userId1}_$userId2',
      extraData: {
        'members': [userId1, userId2],
      },
    );

    await channel.watch();
    return channel;
  }

  Future<Channel> createChannel(String type, String id, String name) async {
    if (client == null) {
      throw Exception(
          "StreamChatClient is not initialized. Call initialize() first.");
    }

    final channel = client!.channel(type, id: id, extraData: {
      'name': name,
    });
    await channel.watch();
    return channel;
  }

  Stream<List<Channel>> getChannels() {
    if (client == null || client!.state.currentUser == null) {
      throw Exception(
          "StreamChatClient is not initialized or user is not connected.");
    }

    final filter = Filter.and([
      Filter.equal('type', 'messaging'),
      Filter.in_('members', [client!.state.currentUser!.id]),
    ]);

    return client!.queryChannels(
      filter: filter,
      channelStateSort: const [
        SortOption<ChannelState>('last_message_at', direction: SortOption.DESC)
      ],
      watch: true,
      state: true,
    );
  }
}
