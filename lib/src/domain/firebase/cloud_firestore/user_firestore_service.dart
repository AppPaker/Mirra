import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';

import 'firestore_service.dart';

class UserFirestoreService implements FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User> getUser(String id) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(id).get();
    if (!snapshot.exists) {
      throw Exception('User not found');
    }
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {
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

  // Unused business methods
  @override
  Future<List<Business>> getAllBusinesses() async {
    throw UnimplementedError();
  }

  @override
  Future<List<Business>> getLocalBusinesses(String location) async {
    throw UnimplementedError();
  }
}
