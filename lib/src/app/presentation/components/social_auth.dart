import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialAuthWidget extends StatelessWidget {
  const SocialAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        IconButton(
          icon: const Icon(FontAwesomeIcons.google),
          onPressed: () {
            // Implement your logic here
          },
        ),

        // Apple
        IconButton(
          icon: const Icon(FontAwesomeIcons.apple),
          onPressed: () {
            // Implement your logic here
          },
        ),

        // Facebook
        IconButton(
          icon: const Icon(FontAwesomeIcons.facebook),
          onPressed: () {
            // Implement your logic here
          },
        ),
      ],
    );
  }
}
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthWidget extends StatelessWidget {
  final Function onGoogleSignIn;
  final Function onAppleSignIn;
  final Function onFacebookSignIn;

  const SocialAuthWidget({
    super.key,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onFacebookSignIn,
  });


  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the process was cancelled, googleUser will be null
      if (googleUser == null) return null;

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase authentication
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credentials
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception {
      // Handle the error if sign in fails
      return null;
    }
  }

  import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthWidget extends StatelessWidget {
  final Function onGoogleSignIn;
  final Function onAppleSignIn;
  final Function onFacebookSignIn;

  const SocialAuthWidget({
    super.key,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onFacebookSignIn,
  });


  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the process was cancelled, googleUser will be null
      if (googleUser == null) return null;

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase authentication
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credentials
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception {
      // Handle the error if sign in fails
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        IconButton(
          icon: const Icon(FontAwesomeIcons.google),
          onPressed: () async {
            try {
              final userCredential = await signInWithGoogle();
              if (userCredential?.user != null) {
                onSignInSuccess();
              } else {
                // Handle the situation if the user cancelled Google sign-in
              }
            } catch (e) {
              // Handle the sign-in error (e.g., display a message)
            }
          },
        ),
        // Apple
        // TODO: Implement Apple sign-in logic
        // Facebook
        // TODO: Implement Facebook sign-in logic
      ],
    );
  }
}

*/
