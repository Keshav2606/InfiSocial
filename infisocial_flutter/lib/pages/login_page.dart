import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:infi_social/controllers/login_controller.dart';
import 'package:infi_social/pages/signup_page.dart';
import 'package:infi_social/components/text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool isLogging = false;
  bool isLoggingWithGoogle = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Email can\'t be empty.')));
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password can\'t be empty.')));
      return;
    }
    setState(() {
      isLogging = true;
    });
    try {

      await LoginController.login(
        context,
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        isLogging = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLogging = false;
        });
      }

      debugPrint('Login error: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoggingWithGoogle = true;
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

      if (user != null) {
        final String? idToken = await user.getIdToken();
        await LoginController.googleLogin(context, idToken);
      }

      setState(() {
        isLoggingWithGoogle = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoggingWithGoogle = false;
      });

      debugPrint('Google Sign-In error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Image.asset(
                      'assets/images/infiSocialLogo.png',
                      height: 120,
                    ),
                    const Text(
                      'InfiSocial',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
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
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
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
                      if (isLogging)
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
                    'assets/images/google_logo.jpeg',
                    height: 24,
                    width: 24,
                  ),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Google'),
                      SizedBox(width: 12),
                      if (isLoggingWithGoogle)
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
    );
  }
}
