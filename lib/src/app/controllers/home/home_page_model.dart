
import 'package:flutter/foundation.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';

import '../../presentation/screens/businesses/businesses.dart';

class HomePageViewModel extends ChangeNotifier {
  final AuthService _authService;
  late final RealFirestoreService _firestoreService = RealFirestoreService();
  //loc.LocationData? _currentLocation;
  String? userId;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  User _user = User(
    id: '',
    firstName: '',
    lastName: '',
    age: 0,
    bio: '',
    mbtiType: '',
    profileImage: '',
    location: '',
  );

  HomePageViewModel({required AuthService authService})
      : _authService = authService {
    userId = _authService.currentUserId;
    // fetchUserData();
    //_initLocation();
  }

  User get user => _user;

  Future<User> fetchUserData() async {
    if (kDebugMode) {
      print('Fetched User ID: $userId');
    }
    try {
      final fetchedUser = await _firestoreService.getUser(userId!);
      if (kDebugMode) {
        print('Using userId for fetch: $userId');
      }

      _user = User(
        id: fetchedUser.id,
        firstName: fetchedUser.firstName,
        lastName: fetchedUser.lastName,
        age: fetchedUser.age,
        bio: fetchedUser.bio ?? '',
        mbtiType: fetchedUser.mbtiType,
        profileImage: fetchedUser.profileImage,
        location: fetchedUser.location,
        city: fetchedUser.city ?? '', // Initialize city
        connectWith: fetchedUser.connectWith ?? [], // Initialize connectWith
        interests: fetchedUser.interests ?? [], // Initialize interests
      );
      if (!_disposed) notifyListeners();
      return _user;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      // Handle the error based on your needs
      return _user; // Return the current user object instead of a new one
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      List<User> users = await _firestoreService
          .getAllUsers(); // Assume this method is implemented in your FirestoreService
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
      return [];
    }
  }

  Future<List<Business>> fetchLocalBusinesses() async {
    final userLocation = user.location;
    try {
      List<Business> businesses =
          await _firestoreService.getLocalBusinesses(userLocation!);
      return businesses;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching local businesses: $e');
      }
      return [];
    }
  }

  Future<void> handleNotificationTap() async {
    // TODO: Implement your notification logic here
    if (kDebugMode) {
      print('Notification tapped');
    }
    if (!_disposed) notifyListeners();
  }
}
