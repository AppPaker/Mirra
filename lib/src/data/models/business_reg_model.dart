import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/presentation/screens/businesses/business_dashboard.dart';
import '../../app/presentation/screens/businesses/business_edit_page/business_profile_page.dart';

class BusinessService {
  /*static Future<void> verifyBusiness(String businessId) async {
    final pendingBusinessRef = FirebaseFirestore.instance
        .collection('pendingBusinesses')
        .doc(businessId);
    final businessData = await pendingBusinessRef.get();

    if (businessData.exists) {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .set({
        ...?businessData.data(),
        'isVerified': true,
      });

      // Optionally, delete the entry from 'pendingBusinesses'
      await pendingBusinessRef.delete();
    }
  }*/
}

class BusinessSignInSignUpModel extends ChangeNotifier {
  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  late TextEditingController businessEmailController = TextEditingController();
  String? Function(String?)? businessEmailControllerValidator;

  late TextEditingController businessPasswordController =
      TextEditingController();
  bool businessPasswordVisibility = false;
  String? Function(String?)? businessPasswordControllerValidator;

  late TextEditingController confirmBusinessPasswordController =
      TextEditingController();
  bool confirmBusinessPasswordVisibility = false;
  String? Function(String?)? confirmBusinessPasswordControllerValidator;

  bool isSignUpMode = false; // Flag to toggle between sign-in and sign-up

  void toggleSignUpMode() {
    isSignUpMode = !isSignUpMode;
    notifyListeners();
  }

  BusinessSignInSignUpModel() {
    businessPasswordVisibility = false;
    businessEmailControllerValidator = _businessEmailControllerValidator;
    businessPasswordVisibility = false;
    businessPasswordControllerValidator = _businessPasswordControllerValidator;
    confirmBusinessPasswordVisibility = false;
    confirmBusinessPasswordControllerValidator =
        _confirmBusinessPasswordControllerValidator;
  }

  @override
  void dispose() {
    super.dispose();
    unfocusNode.dispose();
    businessEmailController.dispose();
    businessPasswordController.dispose();
    confirmBusinessPasswordController.dispose();
  }

  String? _businessEmailControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a business email.';
    }
    if (!val.contains('@')) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  String? _businessPasswordControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a password.';
    }
    if (val.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  String? _confirmBusinessPasswordControllerValidator(String? val) {
    if (val != businessPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> signUpBusiness(
      BuildContext context, String email, String password) async {
    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? uid = userCredential.user?.uid;

      // Add the business's data to a 'businesses' collection directly
      await FirebaseFirestore.instance.collection('businesses').doc(uid).set({
        'email': email,
        'uid': uid,
        'isVerified': true, // Set to true since there's no pending approval
        // Add other fields as needed
      });

      // Optionally, send a verification email if desired

      // Navigate to a different screen or log the business in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessDashboard(
            initialEmail: email,
            id: uid!,
          ),
        ),
      );
    } catch (e) {
      if (e is auth.FirebaseAuthException && e.code == 'email-already-in-use') {
        // Handle the 'email already in use' error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already in use.')),
        );
      } else {
        // Handle other errors
        if (kDebugMode) {
          print("Error signing up business: $e");
        }
        rethrow;
      }
    }
  }

  Future<void> signInBusiness(
      BuildContext context, String email, String password) async {
    try {
      await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String? uid = auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot businessDoc = await FirebaseFirestore.instance
            .collection('businesses')
            .doc(uid)
            .get();

        if (businessDoc.exists) {
          bool isVerified =
              (businessDoc.data() as Map<String, dynamic>)['isVerified'] ??
                  false;
          if (isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BusinessDashboard(
                  initialEmail: email,
                  id: uid,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => BusinessProfileEditPage(
                          initialEmail: email,
                          id: uid,
                        ) //PendingVerificationScreen()),
                    ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Business data not found.')),
          );
        }
      }
    } catch (e) {
      // Handle the error
      if (kDebugMode) {
        print("Error signing in business: $e");
      }
      if (e is auth.FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No user found for that email.')),
            );
            break;
          case 'wrong-password':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wrong password provided.')),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error signing in: ${e.message}')),
            );
        }
      } else {
        rethrow;
      }
    }
  }
}
