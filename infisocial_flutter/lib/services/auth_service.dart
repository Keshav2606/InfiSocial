import 'package:flutter/foundation.dart';
import 'package:infi_social/controllers/login_controller.dart';
import 'package:infi_social/controllers/signup_controller.dart';
import 'package:infi_social/controllers/users_controller.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:hive/hive.dart';

class AuthService extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthService() {
    _initializeAuth();
  }

  /// Initialize authentication by loading stored user data
  Future<void> _initializeAuth() async {
    try {
      final box = await Hive.openBox('userData');
      final userData = box.get('currentUserData');

      if (userData != null) {
        _user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      }
    } catch (e) {
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Sign in and store user data
  Future<UserModel?> signIn(String email, String password) async {
    try {
      debugPrint("Email: $email, Password: $password");
      final user = await SignInController.signIn(
        email: email,
        password: password,
      );

      // debugPrint("User: $user");

      if (user != null) {
        final box = await Hive.openBox('userData');
        await box.put('currentUserData', user.toJson());

        _user = user;
        notifyListeners();
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Google Sign-in and store user data
  Future<UserModel?> signInWithGoogle(String idToken) async {
    try {
      final user = await SignInController.signInWithGoogle(idToken);

      if (user != null) {
        final box = await Hive.openBox('userData');
        await box.put('currentUserData', user.toJson());

        _user = user;
        notifyListeners();
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up and store user data
  Future<UserModel?> signUp({
    required String firstName,
    String lastName = '',
    required String username,
    required String email,
    required String password,
    required String age,
    required String gender,
  }) async {
    try {
      final user = await SignUpController.signUp(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        age: age,
        gender: gender,
      );

      if (user != null) {
        final box = await Hive.openBox('userData');
        await box.put('currentUserData', user.toJson());

        _user = user;
        notifyListeners();
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out and clear stored data
  Future<void> signOut() async {
    final box = await Hive.openBox('userData');
    await box.delete('currentUserData');

    _user = null;
    notifyListeners();
  }

  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
     final user = await UsersController.updateUser(
        userId: userId,
        updateData: updateData,
      );

      if (user != null) {
        final box = await Hive.openBox('userData');
        await box.put('currentUserData', user.toJson());

        _user = user;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
