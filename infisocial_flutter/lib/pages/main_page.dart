import 'package:flutter/material.dart';
import 'package:infi_social/widgets/user_profile_widget.dart';
import 'package:infi_social/models/user_model.dart';
// import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/pages/chats_list_page.dart';
import 'package:infi_social/pages/home_page.dart';
import 'package:infi_social/pages/profile_page.dart';
import 'package:infi_social/pages/add_post_page.dart';
import 'package:infi_social/pages/ai_chatbot_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:provider/provider.dart';
// import 'package:infi_social/services/auth/auth_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  // PageController pageController = PageController();
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<AuthService>(context, listen: false).user;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
    Center(child: HomePage()),
    Center(child: ChatListScreen()),
    Center(child: AddPostPage()),
    Center(child: AIChatbotPage()),
    Center(child: ProfilePage(userId: currentUser!.id!,)),
  ];
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add Post'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.brain), label: 'InfiBot'),
          BottomNavigationBarItem(
            icon: UserProfileWidget(
              userId: currentUser!.id!,
              avatar: currentUser!.avatarUrl!,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
