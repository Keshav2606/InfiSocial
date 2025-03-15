import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://localhost:8000', 
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket.onConnect((_) {
      debugPrint("Connected to server");
    });

    socket.on("receiveMessage", (data) {
      debugPrint("New message: ${data['message']}");
    });

    socket.onDisconnect((_) {
      debugPrint("Disconnected from server");
    });
  }

  void sendMessage(String message, String sender) {
    socket.emit("sendMessage", {
      "sender": sender,
      "message": message,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
