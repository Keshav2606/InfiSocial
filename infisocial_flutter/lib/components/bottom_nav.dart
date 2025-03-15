import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/pages/chats_page.dart';
import 'package:infi_social/pages/home_page.dart';
import 'package:infi_social/pages/profile_page.dart';
import 'package:infi_social/pages/add_post_page.dart';
import 'package:infi_social/pages/ai_chatbot_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int selectedIndex = 0;
  PageController pageController = PageController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> pages = [
    const Center(child: HomePage()),
    Center(child: ChatsPage()),
    const Center(
      child: AddPostPage(),
    ),
    const Center(child: AIChatbotPage()),
    const Center(child: ProfilePage()),
  ];

  @override
  void initState() {
    super.initState();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        key: ValueKey(selectedIndex),
        selectedIconTheme: IconThemeData(
          size: 25,
          color: Theme.of(context).disabledColor,
        ),
        unselectedIconTheme: IconThemeData(
          size: 25,
          color: Theme.of(context).focusColor,
        ),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          onItemTapped(index);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add Post'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.brain), label: 'InfiBot'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
