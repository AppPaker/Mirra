import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../presentation/screens/sign_in_sign_up/email_verification_page.dart';

class SignInSignUpModel extends ChangeNotifier {
  final StorageService storageService;
  late TabController tabController;
  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  Future<void> signUpUser(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    // Check if the email is in the "pre-registration" collection
    bool isPreRegistered = await checkIfPreRegistered(email);

    try {
      auth.UserCredential userCredential;
      if (isPreRegistered) {
        // If the email is pre-registered, copy data from the "pre-registration" document
        // to the user's document in Firestore
        userCredential = await auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String? uid = userCredential.user?.uid;
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);

        // Copy data from "pre-registration" to the user's document
        await copyPreRegistrationData(email, userRef);

        // Remove the user from "pre-registration"
        await removePreRegistration(email);
      } else {
        // If not pre-registered, proceed with regular sign-up
        userCredential = await auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String? uid = userCredential.user?.uid;

        if (uid != null) {
          // Create a new document for the user in Firestore
          DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(uid);

          try {
            await userRef.set({
              'id': uid,
              'email': email,
              // Add other initial fields as necessary
            });
            if (kDebugMode) {
              print("Firestore document created for new user: $uid");
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error creating Firestore document for new user: $e");
            }
          }
        } else {
          if (kDebugMode) {
            print("Error: UID is null after user creation");
          }
        }
      }

// Update the global user state
      final globalUser = context.read<User>(); // Access the global user state
      globalUser.updateUser(User(
        id: userCredential.user?.uid ?? '',
        firstName: '',
        lastName: '',
        age: 0,
        mbtiType: '',
        profileImage: '',
        location: '',
      ));

      // Send verification email
      try {
        await userCredential.user?.sendEmailVerification();
        if (kDebugMode) {
          print("Verification email sent to: $email");
        }

        // Check if email is not verified before navigating
        if (userCredential.user?.emailVerified == false) {
          // Navigate to the EmailVerificationCheckPage
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => EmailVerificationCheckPage(
              storageService: storageService,
            ),
          ));
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error sending verification email: $e");
        }
      }
    } catch (e) {
      // Handle errors, including 'email-already-in-use'
      if (e is auth.FirebaseAuthException && e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'This email is already registered. Please log in or use a different email.')));
      } else {
        if (kDebugMode) {
          print("Error signing up user: $e");
        }
        rethrow;
      }
    }
  }

  // Function to check if the email is in the "pre-registration" collection
  Future<bool> checkIfPreRegistered(String email) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('pre-registration')
          .where('email', isEqualTo: email)
          .limit(
              1) // Limit to 1 document (if there are multiple, we only need one to indicate pre-registration)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking pre-registration: $e');
      }
      return false; // Return false in case of any error
    }
  }

  // Function to copy data from "pre-registration" to the user's document in Firestore
  Future<void> copyPreRegistrationData(
      String email, DocumentReference userRef) async {
    // Implement logic to copy data from "pre-registration" to the user's document
    // This might involve querying the "pre-registration" collection and updating the user's document
    // Example:
    QuerySnapshot preRegSnapshot = await FirebaseFirestore.instance
        .collection('pre-registration')
        .where('email', isEqualTo: email)
        .get();
    if (preRegSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> preRegData =
          preRegSnapshot.docs.first.data() as Map<String, dynamic>;
      await userRef.update({
        'firstName': preRegData['firstName'],
        'lastName': preRegData['lastName'],
        'email': preRegData['email'],
        'subscribeNewsletter': preRegData['subscribeNewsletter'],
        // Add other fields to copy...
      });
    }
  }

  // Function to remove the user from "pre-registration" after copying data
  Future<void> removePreRegistration(String email) async {
    // Implement logic to remove the user from the "pre-registration" collection
    // Example:
    await FirebaseFirestore.instance
        .collection('pre-registration')
        .where('email', isEqualTo: email)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  /*Future<void> signUpUser(
      String email, String password, BuildContext context) async {
    if (email.isEmpty) {
      if (kDebugMode) {
        print("Email is null or empty.");
      }
      return;
    }

    if (password.isEmpty) {
      if (kDebugMode) {
        print("Password is null or empty.");
      }
      return;
    }

    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? uid = userCredential.user?.uid;

      // Add the user's data to Firestore
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await userRef.set({
        'email': email,
        'uid': uid,
        // Add other fields as needed
      });

      // Update the global user state
      final globalUser = context.read<User>(); // Access the global user state
      globalUser.updateUser(User(
        id: uid ?? '',
        firstName:
            '', // You can update these fields later when the user completes their profile
        lastName: '',
        age: 0,
        mbtiType: '',
        profileImage: '',
        location: '',
      ));

      // Send verification email
      try {
        await userCredential.user?.sendEmailVerification();
        if (kDebugMode) {
          print("Verification email sent to: $email");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error sending verification email: $e");
        }
      }

      // Navigate to the EmailVerificationCheckPage
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => EmailVerificationCheckPage(
          storageService: storageService,
        ),
      ));
    } catch (e) {
      if (e is auth.FirebaseAuthException && e.code == 'email-already-in-use') {
        // Handle the 'email already in use' error
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'This email is already registered. Please log in or use a different email.')));
      } else {
        // Handle other errors
        if (kDebugMode) {
          print("Error signing up user: $e");
        }
        rethrow;
      }
    }
  }*/

  Future<void> assignUserNumber(String userId) async {
    // Query Firestore to find the latest user number
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('userNumber', descending: true)
        .limit(1)
        .get();

    int latestUserNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      // If there are existing users, get the latest user number
      latestUserNumber = querySnapshot.docs.first['userNumber'] ?? 0;
    }

    // Increment the latest user number to assign to the new user
    int newUserNumber = latestUserNumber + 1;

    // Update the user's document with the new user number
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'userNumber': newUserNumber});
  }

  late TextEditingController emailAddressController = TextEditingController();
  String? Function(String?)? emailAddressControllerValidator;

  late TextEditingController passwordController = TextEditingController();
  bool passwordVisibility = false;
  String? Function(String?)? passwordControllerValidator;

  late TextEditingController signupemailController = TextEditingController();
  String? Function(String?)? signupemailControllerValidator;

  late TextEditingController passwordsignupController = TextEditingController();
  bool passwordsignupVisibility = false;
  String? Function(String?)? passwordsignupControllerValidator;

  late TextEditingController confirmPasswordController =
      TextEditingController();
  bool confirmPasswordVisibility = false;
  String? Function(String?)? confirmPasswordControllerValidator;

  SignInSignUpModel(TickerProvider vsync, this.storageService) {
    passwordVisibility = false;
    signupemailControllerValidator = _signupemailControllerValidator;
    passwordsignupVisibility = false;
    passwordsignupControllerValidator = _passwordsignupControllerValidator;
    confirmPasswordVisibility = false;
    confirmPasswordControllerValidator = _confirmPasswordControllerValidator;
    tabController = TabController(length: 2, vsync: vsync);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    unfocusNode.dispose();
    emailAddressController.dispose();
    passwordController.dispose();
    signupemailController.dispose();
    passwordsignupController.dispose();
    confirmPasswordController.dispose();
    tabController.dispose();
  }

  String? _signupemailControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter an email.';
    }
    if (!val.contains('@')) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  String? _passwordsignupControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a password.';
    }
    if (val.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  String? _confirmPasswordControllerValidator(String? val) {
    if (val != passwordsignupController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
