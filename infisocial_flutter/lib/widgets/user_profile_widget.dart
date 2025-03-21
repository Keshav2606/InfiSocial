import 'package:flutter/material.dart';
import 'package:infi_social/pages/profile_page.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key, required this.userId, this.avatar = '', this.size = 40.0});

  final String userId;
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId,)));
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
