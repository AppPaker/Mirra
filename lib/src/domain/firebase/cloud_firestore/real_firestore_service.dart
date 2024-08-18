

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/user_feed/comment.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';


import 'firestore_service.dart';

class RealFirestoreService implements FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User> getUser(String id) async {
    if (kDebugMode) {
      print('Fetching user for ID: $id');
    }

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(id).get();
    if (!snapshot.exists) {
      throw Exception('User not found');
    }
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      if (kDebugMode) {
        print('Received user data: $data');
      }
      return User.fromMap(data);
    } else {
      throw Exception('No data found for user');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  @override
  Future<List<User>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    if (snapshot.docs.isEmpty) {
      return [];
    } else {
      return snapshot.docs.map((doc) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    }
  }

  @override
  Future<List<Business>> getAllBusinesses() async {
    QuerySnapshot snapshot = await _firestore.collection('businesses').get();
    if (snapshot.docs.isEmpty) {
      return [];
    } else {
      return snapshot.docs.map((doc) {
        return Business.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    }
  }

  @override
  Future<List<Business>> getLocalBusinesses(String location) async {
    QuerySnapshot snapshot = await _firestore
        .collection('businesses')
        .where('businessLocation', isEqualTo: location)
        .get();
    if (snapshot.docs.isEmpty) {
      return [];
    } else {
      return snapshot.docs.map((doc) {
        return Business.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    }
  }

  @override
  Future<void> setOnboardingCompleted(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'hasCompletedOnboarding': true});
  }

  @override
  Future<bool> hasCompletedOnboarding(String userId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();
    if (!snapshot.exists) {
      return false;
    }
    var data = snapshot.data() as Map<String, dynamic>?;
    return data?['hasCompletedOnboarding'] ?? false;
  }

  Future<DocumentReference<Object?>> addBookingToUser(
      String userId,
      DateTime date,
      TimeOfDay startTime,
      TimeOfDay endTime,
      TimeOfDay preferredTime,
      String businessId) async {
    CollectionReference bookings = _firestore.collection('bookings');

    return bookings.add({
      'userId': userId,
      'businessId': businessId,
      'date': date,
      'startTime': startTime.format(DateTime.now() as BuildContext),
      'endTime': endTime.format(DateTime.now() as BuildContext),
      'preferredTime': preferredTime.format(DateTime.now() as BuildContext),
    });
  }

  Stream<QuerySnapshot> getBookingsForBusiness(String businessId) {
    return _firestore
        .collection('bookings')
        .where('businessId', isEqualTo: businessId)
        .snapshots();
  }

  Future<String> createBooking(
      String matchedUserId, String invitingUserId, String businessId) async {
    DocumentReference bookingRef = await _firestore.collection('bookings').add({
      'matchedUserId': matchedUserId,
      'invitingUserId': invitingUserId,
      'businessId': businessId,
      'status': 'pending', // You can define the status as you like
      'timestamp': FieldValue
          .serverTimestamp(), // To have a timestamp of the booking creation
    });

    return bookingRef.id; // Return the ID of the created booking document
  }

  Future<void> acceptBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
    });
  }

  Future<void> declineBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'declined',
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  Future<void> addLikeToPost(String userId, String postId, String likerId) async {
    final postRef = _firestore
        .collection('users')
        .doc(userId) // User ID of the post owner
        .collection('posts')
        .doc(postId); // Post ID

    await postRef.update({
      'likes': FieldValue.arrayUnion([likerId]),
    });
  }



  Future<void> addCommentToPost(String userId, String postId, UserFeedComment comment) async {
    final postRef = _firestore
        .collection('users')
        .doc(userId) // User ID of the post owner
        .collection('posts')
        .doc(postId); // Post ID

    await postRef.update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });
  }

}


