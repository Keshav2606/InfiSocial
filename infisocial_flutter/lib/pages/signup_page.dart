import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/pages/login_page.dart';
import 'package:infi_social/components/button.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infi_social/components/bottom_nav.dart';
import 'package:infi_social/components/text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isPasswordVisible = false;
  Gender selectedGender = Gender.male;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      addUserDetails(_fullNameController.text, _userNameController.text.trim(),
          _emailController.text, int.parse(_ageController.text));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
        ),
      );
    }
  }

  Future addUserDetails(
      String fullname, String username, String email, int age) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        "user_id": currentUser.uid,
        "isActive": true,
        "username": username,
        "email": email,
        "fullname": fullname,
        "bio": "",
        "avatar": "",
        "followers": [],
        "following": [],
        "createdAt": DateTime.now(),
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            padding: const EdgeInsets.only(
              top: 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/infiSocialLogo.png',
                      height: 120,
                    ),
                    const Text(
                      'InfiSocial',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _fullNameController,
                        hintText: 'Enter your Fullname',
                        labelText: 'Fullname',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Enter your Email Address',
                        labelText: 'Email Id',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomTextField(
                        controller: _userNameController,
                        hintText: 'Enter Username',
                        labelText: 'Username',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _ageController,
                              hintText: 'Enter your Age',
                              labelText: 'Age',
                            ),
                          ),
                          Expanded(
                            child: DropdownButton(
                              value: selectedGender,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(8),
                              hint: const Text('Select Gender'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              items: Gender.values
                                  .map(
                                    (gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender.name.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordVisible,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Create Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Icon(
                              !_isPasswordVisible
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 35.0,
                      ),
                      CustomElevatedButton(onTap: signup, text: 'Signup'),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
