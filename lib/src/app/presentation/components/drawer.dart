import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/mirror_card.dart';
import 'package:mirra/src/app/presentation/components/settings.dart';
import 'package:mirra/src/app/presentation/screens/businesses/nearby_loading_page.dart';
import 'package:mirra/src/app/presentation/screens/chat/matched_list_widget.dart';
import 'package:mirra/src/app/presentation/screens/personality_quiz/openness_quiz_model.dart';
import 'package:mirra/src/app/presentation/screens/personality_quiz/openness_quiz_widget.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/profile_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/sign_in_sign_up/sign_in_sign_up_widget.dart';
import 'package:mirra/src/app/presentation/screens/store/store_widget.dart';
import 'package:mirra/src/app/presentation/screens/subscriptions/subscription_page.dart';
import 'package:mirra/src/app/presentation/screens/track_a_date/track_a_date_widget.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';

import '../utils/constants.dart';
class AppDrawer extends StatelessWidget {
  final String? userId;

  const AppDrawer({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    Widget drawerItem(iconData, String text, Function onTap) {
      return ListTile(
        leading: Icon(
          iconData,
          color: kPurpleColor,
        ),
        minLeadingWidth: 0,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: kPurpleColor,
        ),
        contentPadding: EdgeInsets.zero,
        title: Text(text),
        onTap: () => onTap.call(),
      );
    }

    return Drawer(
        child: SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                drawerItem(
                  Icons.person_rounded,
                  'Profile',
                  () {
                    if (userId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(userId: userId),
                        ),
                      );
                    }
                  },
                ),
                drawerItem(
                  Icons.quiz_rounded,
                  'Personality Quiz',
                  () async {
                    final authService = FirebaseAuthService();
                    final userId = await authService.getUserId();

                    final quizManager = OpennessQuizManager(userId: userId);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            OpennessQuizWidget(quizManager: quizManager),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.thumb_up_rounded,
                  'Matches',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MatchedListPage(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.map_rounded,
                  'Nearby things to do',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoadingPage(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.safety_check,
                  'Track-A-Date',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TrackADatePage(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.subscriptions,
                  'Subscription',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.card_membership,
                  'Mirra Card',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MirrorCard(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.shopping_basket,
                  'Store',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StorePage(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  Icons.settings,
                  'Settings',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(kErrorColor),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kPadding3),
                            ),
                          ),
                        ),
                        onPressed: () {
                          FirebaseAuthService firebaseAuth =
                              FirebaseAuthService();
                          firebaseAuth.logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showDeleteAccountDialog(context),
                  child: Text(
                    'I want to delete my account',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

void _showDeleteAccountDialog(BuildContext context) {
  bool isDeleting = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
                'Are you sure you want to delete your account? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () {
                        setState(() {
                          isDeleting = true;
                        });
                        _deleteAccount(context);
                      },
                child: isDeleting
                    ? const CircularProgressIndicator()
                    : const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> deleteUserFromDatabase(String? userId) async {
  if (userId == null) return;

  // Assuming 'users' is the collection where user data is stored
  await FirebaseFirestore.instance.collection('users').doc(userId).delete();

  // Add additional deletion logic if the user has data in other collections
}

void _deleteAccount(BuildContext context) async {
  try {
    // Assuming you have a method to delete user data from Firestore
    await deleteUserFromDatabase(FirebaseAuth.instance.currentUser?.uid);

    // Delete the user from Firebase Authentication
    await FirebaseAuth.instance.currentUser?.delete();

    // Inform the user of successful account deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Deleted'),
          content: const Text('Your account has been successfully deleted.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const SignInSignUpPage()),
                  ModalRoute.withName('/'),
                );
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting account: $e')),
    );
  }
}
