import 'package:flutter/material.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key, this.avatar = '', this.size = 40.0});

  final String avatar;
  final double? size;

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return Expanded(
                child: widget.avatar != ''
                    ? Image.network(widget.avatar)
                    : const Icon(Icons.person),
              );
            });
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[600],
        ),
        child: widget.avatar != ''
            ? ClipOval(
                child: Image.network(
                  widget.avatar,
                  fit: BoxFit.contain,
                ),
              )
            : const Icon(Icons.person),
      ),
    );
  }
}
