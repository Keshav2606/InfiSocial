import 'package:flutter/material.dart';
import 'package:infi_social/controllers/users_controller.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/stream_chat_service.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  // final _formKey = GlobalKey<FormState>();
  // final _nameController = TextEditingController();
  // final _idController = TextEditingController();
  bool _isLoading = false;

  List<UserModel?> allUsers = [];
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    getAllUsers();
    currentUser = Provider.of<AuthService>(context, listen: false).user;
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _idController.dispose();

    super.dispose();
  }

  Future<void> getAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final _users = await UsersController.getAllUsers();

      setState(() {
        allUsers = _users.where((user) => user!.id != currentUser!.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _createChannel(String userId1, String userId2) async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final streamChatService =
          Provider.of<StreamChatService>(context, listen: false);

      // final channelId = _idController.text.trim().isEmpty
      //     ? DateTime.now().millisecondsSinceEpoch.toString()
      //     : _idController.text.trim();

      await streamChatService.createOneToOneChannel(userId1, userId2);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create channel: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : allUsers.isEmpty
                  ? Text('No users found')
                  : ListView.builder(
                      itemCount: allUsers.length,
                      itemBuilder: (context, index) {
                        final user = allUsers[index];
                        return ListTile(
                          onTap: () {
                            _createChannel(currentUser!.id!, user.id!);
                          },
                          title: Text("${user!.firstName} ${user.lastName}"),
                        );
                      }),
        ),
        // Form(
        //   key: _formKey,
        //   child: Column(
        //     children: [
        //       TextFormField(
        //         controller: _nameController,
        //         decoration: InputDecoration(labelText: 'Channel Name'),
        //         validator: (value) {
        //           if (value == null || value.isEmpty) {
        //             return 'Please enter a channel name';
        //           }
        //           return null;
        //         },
        //       ),
        //       SizedBox(height: 16),
        //       TextFormField(
        //         controller: _idController,
        //         decoration: InputDecoration(
        //           labelText: 'Channel ID (Optional)',
        //           helperText: 'Leave blank for auto-generated ID',
        //         ),
        //       ),
        //       SizedBox(height: 24),
        //       _isLoading
        //           ? CircularProgressIndicator()
        //           : ElevatedButton(
        //               onPressed: _createChannel,
        //               child: Text('Create Channel'),
        //             ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
