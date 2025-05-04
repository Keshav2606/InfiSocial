import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infi_social/pages/main_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:infi_social/pages/signup_page.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/widgets/text_field_widget.dart';
import 'package:infi_social/services/stream_chat_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLogging = false;
  bool _isLoggingWithGoogle = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLogging = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final streamChatService =
          Provider.of<StreamChatService>(context, listen: false);

      final user = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        // disConnect to Stream Chat before connecting.
        await streamChatService.disconnectUser();
        // Connect to Stream Chat
        await streamChatService.connectUser(
          user.id!,
          user.username,
          user.avatarUrl,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to sign in: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLogging = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoggingWithGoogle = true;
    });
    try {
      // Disconnect to clear previous session
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      // Step 1: Initiate Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint('Google sign-in was cancelled.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in was cancelled.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      debugPrint("Hii_1");

      if (user != null) {
        final String? idToken = await user.getIdToken();
        debugPrint("Hii_2");
        if (idToken != null) {
          debugPrint("Hii_3");
          final authService = Provider.of<AuthService>(context, listen: false);
          final streamChatService =
              Provider.of<StreamChatService>(context, listen: false);

          final _user = await authService.signInWithGoogle(idToken);

          if (_user != null) {
            debugPrint("Hii_4");
            await streamChatService.disconnectUser();
            await streamChatService.connectUser(
              _user.id!,
              _user.username,
              _user.avatarUrl,
            );

            debugPrint("Hii_5");

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MainPage()),
            );
          }
        }
      }

      setState(() {
        _isLoggingWithGoogle = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingWithGoogle = false;
      });

      debugPrint('Google Sign-In error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          'assets/images/infiSocialLogo.png',
                          height: 120,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Enter Email',
                    labelText: 'Email',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email can't be empty";
                      } else if (!value.contains(
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'))) {
                        return 'Please enter a vaild email address';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Password can't be empty";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      hintText: 'Enter Password',
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
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Login'),
                        SizedBox(width: 12),
                        if (_isLogging)
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
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        child: const Text(
                          'Signup',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      const SizedBox(width: 8),
                      const Text(
                        'Or continue with',
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Google'),
                        SizedBox(width: 12),
                        if (_isLoggingWithGoogle)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
