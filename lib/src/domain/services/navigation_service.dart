import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/sign_in_sign_up/sign_in_sign_up_widget.dart';
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  Future<void> navigateToAuth() async {
    await navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInSignUpPage()),
        (value) => false);
  }
}
