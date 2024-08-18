import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';

import 'firestore_service.dart';

class BusinessFirestoreService implements FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> addBusinessToFirestore(Business business) async {
    try {
      await _firestore.collection('businesses').add({
        ...business.toMap(),
        'name_lowercase': business.name.toLowerCase(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding business to Firestore: $e');
      }
      throw Exception('Failed to add business to Firestore');
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

  Future<bool> businessExists(
      String? placeId, String name, String address) async {
    // Check if placeId is not null and not empty
    if (placeId != null && placeId.isNotEmpty) {
      // First, try to find a business with 'placeId'
      var snapshot = await _firestore
          .collection('businesses')
          .where('placeId', isEqualTo: placeId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return true;
      }

      // If not found, try to find a business with 'place_id'
      snapshot = await _firestore
          .collection('businesses')
          .where('place_id', isEqualTo: placeId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return true;
      }
    } else {
      // If placeId is null, check using name and address
      var snapshot = await _firestore
          .collection('businesses')
          .where('name', isEqualTo: name)
          .where('address', isEqualTo: address)
          .get();

      return snapshot.docs.isNotEmpty;
    }

    // If no business is found
    return false;
  }

  // Unused user methods
  @override
  Future<User> getUser(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUser(User user) async {
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getAllUsers() async {
    throw UnimplementedError();
  }

  @override
  Future<void> setOnboardingCompleted(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasCompletedOnboarding(String userId) async {
    throw UnimplementedError();
  }
}
