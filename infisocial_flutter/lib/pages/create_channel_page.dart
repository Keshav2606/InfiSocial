import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stream_chat_service.dart';

class CreateChannelScreen extends StatefulWidget {

  const CreateChannelScreen({super.key});
  
  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _createChannel() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final streamChatService = Provider.of<StreamChatService>(context, listen: false);
      
      final channelId = _idController.text.trim().isEmpty 
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : _idController.text.trim();
      
      await streamChatService.createChannel(
        'messaging',
        channelId,
        _nameController.text.trim(),
      );
      
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
      appBar: AppBar(title: Text('Create Channel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Channel Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a channel name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Channel ID (Optional)',
                  helperText: 'Leave blank for auto-generated ID',
                ),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createChannel,
                      child: Text('Create Channel'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}