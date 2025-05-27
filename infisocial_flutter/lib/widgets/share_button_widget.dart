import 'package:flutter/material.dart';
import 'package:infi_social/models/post_model.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:infi_social/controllers/posts_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareButton extends StatefulWidget {
  const ShareButton({super.key, required this.postId});

  final String postId;

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          // Fetch post data with error handling
          final post = await PostsController.getPostById(widget.postId);
          if (post != null && mounted) {
            // Show share options bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => ShareOptionsSheet(post: post),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post not found')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading post: $e')),
            );
          }
        }
      },
      icon: const Icon(FontAwesomeIcons.share),
      tooltip: 'Share Post',
    );
  }
}

class ShareOptionsSheet extends StatelessWidget {
  final PostModel post;

  const ShareOptionsSheet({super.key, required this.post});

  // Handle send via DM
  void _sendViaDM(BuildContext context) {
    final streamChatClient = StreamChat.of(context).client;
    final currentUser = StreamChat.of(context).currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send to...'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamChannelListView(
            controller: StreamChannelListController(
              client: streamChatClient,
              filter: Filter.and([
                Filter.equal('type', 'messaging'),
                Filter.in_('members', [currentUser.id]),
              ]),
              channelStateSort: const [SortOption('last_message_at')],
              limit: 20,
            ),
            itemBuilder: (context, channels, index, defaultWidget) {
              final channel = channels[index];
              return ListTile(
                leading: StreamChannelAvatar(channel: channel),
                title: StreamChannelName(channel: channel),
                subtitle: channel.state?.lastMessage != null
                    ? StreamMessageText(
                        message: channel.state!.lastMessage!,
                        messageTheme: StreamMessageThemeData(),
                      )
                    : const Text('No messages yet'),
                onTap: () => _shareToChannel(context, dialogContext, channel),
              );
            },
            emptyBuilder: (context) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No conversations yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Separate method to handle sharing to a specific channel
  Future<void> _shareToChannel(
    BuildContext context,
    BuildContext dialogContext,
    Channel channel,
  ) async {
    try {
      // Show loading
      showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (loadingContext) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Sharing post...'),
            ],
          ),
        ),
      );

      // Watch the channel to ensure it's active
      await channel.watch();

      // Create message without problematic attachments
      final message = Message(
        text: _buildShareText(),
        extraData: {
          'shared_post_id': post.postId,
          'shared_post_type': 'social_post',
          'shared_from': 'infisocial',
          'original_content': post.content,
          if (post.mediaUrl.isNotEmpty) 'original_media_url': post.mediaUrl,
        },
      );

      // Send the message
      await channel.sendMessage(message);

      // Close loading dialog
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      if (context.mounted) {
        // Close both dialogs
        Navigator.pop(dialogContext); // Close channel selection dialog
        Navigator.pop(context); // Close share options sheet

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post shared to ${_getChannelName(channel)}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      if (context.mounted) {
        Navigator.pop(dialogContext);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Build share message text
  String _buildShareText() {
    try {
      final StringBuffer messageBuffer = StringBuffer();

      messageBuffer.writeln('📤 Shared Post from InfiSocial');
      messageBuffer.writeln();

      // Add content if available
      if (post.content.isNotEmpty) {
        final content = post.content.length > 150
            ? '${post.content.substring(0, 150)}...'
            : post.content;
        messageBuffer.writeln(content);
        messageBuffer.writeln();
      }

      // Add media info if available
      if (post.mediaUrl.isNotEmpty) {
        messageBuffer.writeln('📸 Contains media');
        messageBuffer.writeln();
      }

      // Add post link if ID is available
      if (post.postId.isNotEmpty) {
        messageBuffer.writeln(
            '🔗 View original: https://infisocial.com/posts/${post.postId}');
      }

      return messageBuffer.toString().trim();
    } catch (e) {
      return '📤 A post was shared with you from InfiSocial';
    }
  }

  // Get readable channel name
  String _getChannelName(Channel channel) {
    return channel.name ??
        channel.extraData['name']?.toString() ??
        'conversation';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with post preview
          Row(
            children: [
              const Icon(FontAwesomeIcons.share, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Share Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Post preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.content.isNotEmpty)
                  Text(
                    post.content.length > 100
                        ? '${post.content.substring(0, 100)}...'
                        : post.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                if (post.mediaUrl.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(post.mediaUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(FontAwesomeIcons.message, color: Colors.green),
            title: const Text('Send via DM'),
            subtitle: const Text('Share privately with friends'),
            onTap: () => _sendViaDM(context),
          ),
          const SizedBox(height: 16),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
