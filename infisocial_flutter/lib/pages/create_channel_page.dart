import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stream_chat_service.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/controllers/users_controller.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  bool _isLoading = false;

  List<UserModel?> allUsers = [];
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    getAllUsers();
    currentUser = Provider.of<AuthService>(context, listen: false).user;
  }

  Future<void> getAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UsersController.getAllUsers();

      setState(() {
        allUsers = users.where((user) => user!.id != currentUser!.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _createChannel(String userId1, String userId2) async {
    setState(() => _isLoading = true);

    try {
      final streamChatService =
          Provider.of<StreamChatService>(context, listen: false);

      await streamChatService.createOneToOneChannel(userId1, userId2);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create channel: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  hintText: "Search...",
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : allUsers.isEmpty
                      ? Center(child: Text('No users found'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: allUsers.length,
                            itemBuilder: (context, index) {
                              final user = allUsers[index];
                              return ListTile(
                                onTap: () {
                                  _createChannel(currentUser!.id!, user.id!);
                                },
                                title:
                                    Text("${user!.firstName} ${user.lastName}"),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: user.avatarUrl != null &&
                                          user.avatarUrl != ''
                                      ? Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.network(
                                            user.avatarUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(Icons.person),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
