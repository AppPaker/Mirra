import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'chat_model.dart';
import '../../app/presentation/screens/chat/chat_widget.dart';

class UserModel {
  final String firstName;
  final String profileImage;
  final String mbtiType;
  final int age;
  final String location;
  final double? matchRating;
  final String uid;

  UserModel({
    required this.firstName,
    required this.profileImage,
    required this.mbtiType,
    required this.age,
    required this.location,
    this.matchRating,
    required this.uid,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      if (kDebugMode) {
        print("Document data is null!");
      }
      // Handle this case or throw an error if needed
      throw Exception("Document data is null for user with ID: ${doc.id}");
    }

    if (kDebugMode) {
      print("Document data: $data");
    } // This will show you the full data in the document

    String? firstName;
    if (data.containsKey('firstName')) {
      firstName = data['firstName'];
    } else {
      if (kDebugMode) {
        print("firstName is missing!");
      }
    }

    String? profileImage;
    if (data.containsKey('profileImage')) {
      profileImage = data['profileImage'];
    } else {
      if (kDebugMode) {
        print("profileImage is missing!");
      }
    }

    String? mbtiType;
    if (data.containsKey('mbtiType')) {
      mbtiType = data['mbtiType'];
    } else {
      if (kDebugMode) {
        print("mbtiType is missing!");
      }
    }

    int? age;
    if (data.containsKey('age')) {
      age = data['age'];
    } else {
      if (kDebugMode) {
        print("age is missing!");
      }
    }

    String? location;
    if (data.containsKey('location')) {
      location = data['location'];
    } else {
      if (kDebugMode) {
        print("location is missing!");
      }
    }

    double? matchRating;
    if (data.containsKey('matchRating')) {
      matchRating = data['matchRating'].toDouble();
    } else {
      if (kDebugMode) {
        print("matchRating is missing!");
      }
    }

    return UserModel(
      firstName: firstName ?? "Unknown",
      profileImage: profileImage ?? "Unknown",
      mbtiType: mbtiType ?? "Unknown",
      age: age ?? 0,
      location: location ?? "Unknown",
      matchRating: matchRating,
      // This can remain null if not present
      uid: doc.id,
    );
  }
}

enum SwipeAction { like, superlike, dislike }

class SwipeCardModel extends ChangeNotifier {

  final AuthService authService;
  final Function(User, String) onMatchFound;
  List<User> users = [];
  String? currentUserUid;
  DocumentSnapshot? lastDocument;
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;

  SwipeCardModel({required this.authService, required this.onMatchFound}) {
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    currentUserUid = await authService.getUserId();
    await fetchUsers(1, 10);
  }

  Future<bool> fetchUsers(int currentPage, int usersPerPage) async {
    try {
      var interactedUsers = await fetchInteractedUsers();
      Map<String, dynamic> filters = await getFilters();

      if (kDebugMode) {
        print("entries$filters");
      }

      Query query = FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserUid);

      // Apply filters based on the user's preferences
      // Uncomment the filters one by one for testing

      // Age Range Filter
      if (filters.containsKey('ageRangeStart') &&
          filters.containsKey('ageRangeEnd')) {
        query = query
            .where('age', isGreaterThanOrEqualTo: filters['ageRangeStart'])
            .where('age', isLessThanOrEqualTo: filters['ageRangeEnd']);
      }

      // Gender Filter
      if (filters.containsKey('genders') &&
          (filters['genders'] as List).isNotEmpty) {
        query = query.where('gender', whereIn: filters['genders']);
      }

      // Looking For Filter
      if (filters.containsKey('lookingFor')) {
        query = query.where('lookingFor', whereIn: filters['lookingFor']);
      }

      // // Orientation Filter
      // if (filters.containsKey('orientations')) {
      //   query = query.where('orientation', whereIn: filters['orientations']);
      // }

      // Religion Filter
      if (filters.containsKey('religions')) {
        query = query.where('religion', whereIn: filters['religions']);
      }

      // Interests Filter
      if (filters.containsKey('interests')) {
        query =
            query.where('interests', arrayContainsAny: filters['interests']);
      }

      // Pagination Logic
      // if (lastDocument != null) {
      //   query = query.startAfterDocument(lastDocument!);
      // }

      QuerySnapshot querySnapshot = await query.limit(usersPerPage).get();

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }

      List<User> fetchedUsers = [];
      for (var doc in querySnapshot.docs) {
        // Exclude users already interacted with and the current user
        if (!interactedUsers.contains(doc.id) && doc.id != currentUserUid) {
          try {
            fetchedUsers.add(User.fromDocument(doc));
          } catch (e) {
            if (kDebugMode) {
              print("Error processing document with ID: ${doc.id}. Error: $e");
            }
            // Skipping the document in case of error
          }
        }
      }

      // Update the users list and generate MatchEngine
      users = fetchedUsers;
      notifyListeners();
      await generateMatchEngine();
      notifyListeners(); // Call this function to initialize MatchEngine
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users: $e");
      }
      notifyListeners();
      return false; // Return an empty list in case of error
    }
  }


  Future<List<String>> fetchInteractedUsers() async {
    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    final matchEngineRef =
        currentUserRef.collection('matchEngine').doc('actions');
    DocumentSnapshot doc = await matchEngineRef.get();

    if (!doc.exists) {
      if (kDebugMode) {
        print("No interactions found for the user");
      }
      return [];
    }

    List<String> allInteractedUsers = [];
    if (doc.exists) {
      allInteractedUsers = [
        ...doc.get('likes'),
        ...doc.get('superlikes'),
        ...doc.get('dislikes')
      ];
    }

    return allInteractedUsers;
  }

  Future<void> onSwipe(User targetUser, SwipeAction action) async {
    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    final matchEngineRef =
        currentUserRef.collection('matchEngine').doc('actions');

    DocumentSnapshot doc = await matchEngineRef.get();

    if (!doc.exists) {
      await matchEngineRef.set({'likes': [], 'superlikes': [], 'dislikes': []});
    }

    String actionField;
    switch (action) {
      case SwipeAction.like:
        actionField = 'likes';
        break;
      case SwipeAction.superlike:
        actionField = 'superlikes';
        break;
      case SwipeAction.dislike:
        actionField = 'dislikes';
        break;
      default:
        return;
    }

    await matchEngineRef.update({
      actionField: FieldValue.arrayUnion([targetUser.id])
    });

    // Check for a match only if the current action is a 'like' or 'superlike'
    if (action == SwipeAction.like || action == SwipeAction.superlike) {
      final targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(targetUser.id);
      final targetMatchEngineRef =
          targetUserRef.collection('matchEngine').doc('actions');
      DocumentSnapshot targetDoc = await targetMatchEngineRef.get();

      if (targetDoc.exists &&
          (targetDoc.get('likes').contains(currentUserUid) ||
              targetDoc.get('superlikes').contains(currentUserUid))) {
        // Both users have liked or superliked each other, it's a match!
        await handleMatch(currentUserUid!, targetUser.id);
      }
    }
  }

  void showMatchDialog(BuildContext context, User matchedUser, String matchId) {
    if (Navigator.canPop(context)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("It's a Match!"),
            content: Text('You matched with ${matchedUser.firstName}!'),
            actions: <Widget>[
              TextButton(
                child: const Text('Chat Now'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatPage(
                          matchedUser: matchedUser, matchId: matchId)));
                },
              ),
              TextButton(
                child: const Text('Keep Swiping'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> handleMatch(String user1Id, String user2Id,
      [BuildContext? context]) async {
    final matchesRef = FirebaseFirestore.instance.collection('matches');
    final usersRef = FirebaseFirestore.instance.collection('users');

    // Create a list of the two user IDs and sort them
    List<String> userIds = [user1Id, user2Id]..sort();

    // Create a unique match ID based on the sorted user IDs
    String matchId = userIds.join('_');

    // Add the match to the database
    await matchesRef.doc(matchId).set({
      'users': userIds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Create an initial chat for the match
    final chatModel = ChatModel();
    await chatModel.createChatForMatch(matchId);

    // Fetch matched user data for the dialog.
    DocumentSnapshot userDoc = await usersRef.doc(user2Id).get();
    User matchedUser = User.fromDocument(userDoc);

    // Show the match dialog
    onMatchFound(matchedUser, matchId);

    // Assuming currentUser is fetched earlier in your code
    String currentUserUid = auth.FirebaseAuth.instance.currentUser?.uid ?? '';
    User currentUser = await usersRef
        .doc(currentUserUid)
        .get()
        .then((doc) => User.fromDocument(doc));

    // Determine the receiver based on the current user's ID
    String receiverId = user1Id == currentUserUid ? user2Id : user1Id;

    // Access your NotificationProvider
    // Ensure that NotificationProvider is correctly provided higher up in the widget tree
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context!, listen: false);

    // Send notification about the match
    notificationProvider.sendNotificationToUser(
      receiverId: receiverId,
      senderId: currentUserUid,
      senderName: currentUser.firstName ?? 'Unknown',
      title: 'New Match!',
      body: 'You have a new match with ${matchedUser.firstName}.',
      inviteStatus:
          'Pending', // Since it's a match, you might use a different status or handle it accordingly
    );
  }

  generateMatchEngine() {
    swipeItems = users.map((User user) {
      return SwipeItem(
        content: user,
        likeAction: () async {
          if (kDebugMode) {
            print('Liked ${user.firstName}');
          }
          await onSwipe(user, SwipeAction.like);
        },
        nopeAction: () async {
          if (kDebugMode) {
            print('Nope ${user.firstName}');
          }
          await onSwipe(user, SwipeAction.dislike);
        },
        superlikeAction: () async {
          if (kDebugMode) {
            print('Superliked ${user.firstName}');
          }
          await onSwipe(user, SwipeAction.superlike);
        },
      );
    }).toList();

    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  Future<Map<String, dynamic>> getFilters() async {
    DocumentSnapshot filterDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('filters')
        .doc('userFilters')
        .get();

    if (filterDoc.exists) {
      return filterDoc.data() as Map<String, dynamic>;
    } else {
      if (kDebugMode) {
        print("No filters set for the user");
      }
      return {}; // Return default filters or an empty map if no filters are set
    }
  }
}
