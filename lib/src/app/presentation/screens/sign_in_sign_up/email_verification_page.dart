import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../../controllers/users/create_profile_model.dart';
import '../create_profile/create_profile_widget.dart';

class EmailVerificationCheckPage extends StatefulWidget {
  final StorageService storageService;

  const EmailVerificationCheckPage({super.key, required this.storageService});

  @override
  _EmailVerificationCheckPageState createState() =>
      _EmailVerificationCheckPageState();
}

class _EmailVerificationCheckPageState
    extends State<EmailVerificationCheckPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kPadding4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please check your email and verify your account.'),
              const SizedBox(height: kPadding4),
              Row(
                children: [
                  Expanded(
                    child: MirrorElevatedButton(
                      onPressed: _checkEmailVerified,
                      child: const Text('Check Verification Status'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _checkEmailVerified() async {
    await _auth.currentUser?.reload();
    if (kDebugMode) {
      print("Is email verified: ${_auth.currentUser?.emailVerified}");
    }
    if (_auth.currentUser?.emailVerified == true) {
      // If email is verified, navigate to CreateProfilePage
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<CreateProfileModel>(
          create: (context) => CreateProfileModel(
              storageService: widget.storageService,
              userId: _auth.currentUser?.uid),
          child: const CreateProfilePage(),
        ),
      ));
      if (kDebugMode) {
        print("Current User ID: ${_auth.currentUser?.uid}");
      }
    } else {
      // If not verified, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email has not been verified yet.')),
      );
    }
  }
}
