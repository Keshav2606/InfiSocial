import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:infi_social/components/bottom_nav.dart';
import 'package:infi_social/pages/login_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();

    getLoginStatus();
  }

  void getLoginStatus() async {
    final box = await Hive.openBox('userData');
    final isLoggedin = await box.get('isLoggedin', defaultValue: false);

    Timer(const Duration(milliseconds: 3000), () {
      if (isLoggedin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigation()),
        );
      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                const Color.fromARGB(255, 1, 81, 146),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/infiSocialLogo.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              RichText(
                textScaler: TextScaler.linear(3),
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Infi",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                      text: "Social",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
