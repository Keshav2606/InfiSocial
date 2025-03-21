import 'package:flutter/material.dart';
import 'package:infi_social/pages/login_page.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/widgets/text_field_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infi_social/services/auth_service.dart';
// import 'package:infi_social/services/stream_chat_service.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  bool _isSigningUp = false;
  bool _isPasswordVisible = false;
  Gender selectedGender = Gender.male;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void signup() async {
    setState(() {
      _isSigningUp = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // final streamChatService = Provider.of<StreamChatService>(context, listen: false);
      
      await authService.signUp(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _userNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        age: _ageController.text,
        gender: selectedGender.name,
      );
      setState(() {
      _isSigningUp = false;
    });
    } catch (error) {
      setState(() {
      _isSigningUp = false;
    });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                        controller: _firstNameController,
                        hintText: 'Enter your First Name',
                        labelText: 'First Name',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomTextField(
                        controller: _lastNameController,
                        hintText: 'Enter your Last Name',
                        labelText: 'Last Name',
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
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Enter your Email Address',
                        labelText: 'Email Id',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomTextField(
                        controller: _ageController,
                        hintText: 'Enter your Age',
                        labelText: 'Age',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      DropdownButtonFormField(
                        value: selectedGender,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(8),
                        hint: const Text('Select Gender'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: Gender.values
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
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
                              _isPasswordVisible
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
                      ElevatedButton(
                        onPressed: signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Signup'),
                            SizedBox(width: 12),
                            if (_isSigningUp)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
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
