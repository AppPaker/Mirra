import 'package:flutter/material.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';

import '../../presentation/screens/home/home_page_widget.dart';

class SignInModel with ChangeNotifier {
  final AuthService _authService = FirebaseAuthService();

  String email = '';
  String password = '';

  void updateEmail(String value) {
    email = value.trim();
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value.trim();
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signInUser(email, password);
      // Notify listeners or handle post-sign-in logic here
    } catch (e) {
      // Handle the error (e.g., notify listeners about the error)
      rethrow;
    }
  }

  Future<void> navigateToHomePage(BuildContext context) async {
    try {
      await signIn(email, password);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomePage(),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
