import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:mirra/src/app/presentation/screens/chat/chat_widget.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';

// Import other necessary packages

class UserService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid; // If the user is not logged in, this will return null.
  }

  Future<List<Map<String, dynamic>>> fetchMatchesForCurrentUser() async {
    String? currentUserId = await authService.getUserId();

    final matchesRef = FirebaseFirestore.instance.collection('matches');
    final querySnapshot =
        await matchesRef.where('users', arrayContains: currentUserId).get();
    if (kDebugMode) {
      print('Matches for current user: ${querySnapshot.docs.length}');
    }

    List<Map<String, dynamic>> matches = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      matches.add({
        'matchId': doc.id,
        'userId': data['users']
            .firstWhere((id) => id != currentUserId, orElse: () => null),
      });
    }
    return matches;
  }

  Future<List<User>> convertMatchesToUsers(
      List<Map<String, dynamic>> matches) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    List<User> users = [];

    for (var match in matches) {
      final doc = await usersRef.doc(match['userId']).get();
      if (doc.exists) {
        final user = User.fromDocument(doc);
        user.matchId = match['matchId']; // Setting the matchId for the user
        users.add(user);
        if (kDebugMode) {
          print(
              'Document exists for user: ${match['userId']}, with Match ID: ${user.matchId}');
        }
      } else {
        if (kDebugMode) {
          print('No document for user: ${match['userId']}');
        }
      }
    }
    return users;
  }

  Future<List<User>> fetchMatchedUsers() async {
    try {
      List<Map<String, dynamic>> matches = await fetchMatchesForCurrentUser();
      return await convertMatchesToUsers(matches);
    } catch (error) {
      if (kDebugMode) {
        print('Error in fetchMatchedUsers: $error');
      }
      return [];
    }
  }

  Future<User> fetchUserById(String userId) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final doc = await usersRef.doc(userId).get();
    if (doc.exists) {
      return User.fromDocument(
          doc); // Assuming User has a constructor to create an instance from Firestore document
    } else {
      throw Exception('User not found');
    }
  }

  Future<DocumentReference> addDateToUser({
    required String userId,
    required DateTime started,
    DateTime? finished,
    required String locationName,
    required String locationAddress,
    required bool active,
    String? trustedContactEmail,
    String? placeId,
    required Map<String, dynamic> matchData,
  }) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    DocumentReference userDocRef = usersCollection.doc(userId);
    CollectionReference datesCollection = userDocRef.collection('dates');

    return await datesCollection.add({
      'started': started.toIso8601String(),
      'finished': finished?.toIso8601String(),
      'location': {
        'name': locationName,
        'address': locationAddress,
        'placeId': placeId,
      },
      'active': active,
      'trustedContactEmail': trustedContactEmail,
      'match': matchData,
    });
  }

  Future<void> updateDateForUser({
    required String userId,
    required String dateDocId,
    required DateTime finished,
    required bool active,
  }) async {
    DocumentReference dateDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dates')
        .doc(dateDocId);

    await dateDocRef.update({
      'finished': finished.toIso8601String(),
      'active': active,
    });
  }

  Future<void> updateDateLocation({
    required String userId,
    required String dateDocId,
    required LocationData locationData,
  }) async {
    DocumentReference dateDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('dates')
        .doc(dateDocId);

    await dateDocRef.update({
      'latestLocation': {
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        // Include any other location details you need, like street address
      },
    });
  }

  Future<void> updateLocationInFirestore(
      String dateDocId, String newLocation, String userId) async {
    DocumentReference dateDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId) // Make sure you have the correct userId
        .collection('dates')
        .doc(dateDocId);

    await dateDocRef.update({
      'updatedLocation':
          newLocation, // Add this field in your Firestore document
    });
  }

// Any additional methods or logic...
}
