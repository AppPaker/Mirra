import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';

class ProfilePageViewModel extends ChangeNotifier {
  final RealFirestoreService _firestoreService = RealFirestoreService();
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  loc.LocationData? _currentLocation;
  var location = loc.Location();
  String? userId;
  bool _disposed = false;
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return "${place.locality}, ${place.country}";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Unknown Location";
    }
  }

  TextEditingController suggestionController = TextEditingController();
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  int _currentPage = 0;
  bool _showFullBio = false;

  User _user = User(
    id: '',
    firstName: '',
    lastName: '',
    age: 0,
    bio: '',
    mbtiType: '',
    profileImage: '',
    location: '',
    city: '', // Initialize city
    connectWith: [], // Initialize connectWith
    interests: [], // Initialize interests
  );

  ProfilePageViewModel({required AuthService authService, required this.userId}) {
    fetchUserData();
    _initLocation();
  }

  _initLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();

    if (_currentLocation != null) {
      try {
        String cityName = await getLocationName(
            _currentLocation!.latitude!, _currentLocation!.longitude!);
        _user = _user.copyWith(city: cityName); // Update the user's city
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print("Error converting location: $e");
        }
      }
    }
  }

  LocationData? get currentLocation => _currentLocation;

  int get currentPage => _currentPage;
  bool get showFullBio => _showFullBio;
  User get user => _user;

  void onPageChanged(int page) {
    _currentPage = page;
    if (!_disposed) notifyListeners();
  }

  void toggleBioVisibility() {
    _showFullBio = !_showFullBio;
    if (!_disposed) notifyListeners();
  }

  Future<User> fetchUserData() async {
    if (kDebugMode) {
      print('Fetched User ID: $userId');
    }
    try {
      final fetchedUser = await _firestoreService.getUser(userId!);
      _user = User(
        id: fetchedUser.id,
        firstName: fetchedUser.firstName,
        lastName: fetchedUser.lastName,
        age: fetchedUser.age,
        bio: fetchedUser.bio ?? '',
        mbtiType: fetchedUser.mbtiType,
        profileImage: fetchedUser.profileImage,
        otherImages: fetchedUser.otherImages,
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

  Future<void> fetchAndUpdateUserData(String fetchedUserId) async {
    try {
      User fetchedUser = await _firestoreService.getUser(fetchedUserId);

      // Update your local _user object
      _user = fetchedUser;
      notifyListeners();
    } catch (e) {
      // Handle errors appropriately
      if (kDebugMode) {
        print('Error fetching or updating user data: $e');
      }
    }
  }

  Future<void> addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String imageUrl = await _storageService.uploadImageToFirebase(
        _user.id,
        io.File(pickedFile.path),
        _user.otherImages?.length ?? 0,
      );
      _user.otherImages ??= [];
      _user.otherImages!.add(imageUrl);
      _user.profileImage = imageUrl;
      await _firestoreService.updateUser(_user);
      if (!_disposed) notifyListeners();
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  Future<void> updateProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String imageUrl = await _storageService.uploadProfileImage(
        _user.id,
        io.File(pickedFile.path),
      );

      // Get placemark from coordinates
      String location = '';
      if (_currentLocation != null) {
        final placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude ?? 0.0,
          _currentLocation!.longitude ?? 0.0,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          location = '${placemark.locality}, ${placemark.country}';
        }
      }

      _user = User(
        id: _user.id,
        firstName: _user.firstName,
        lastName: _user.lastName,
        age: _user.age,
        bio: _user.bio,
        mbtiType: _user.mbtiType,
        profileImage: imageUrl,
        otherImages: _user.otherImages,
        location: location,
      );

      await _firestoreService.updateUser(_user);
      if (!_disposed) notifyListeners();
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  // Setters to update user data
  set bio(String value) {
    _user.bio = value;
  }

  set otherImages(List<String> values) {
    _user.otherImages = values;
  }

  set profileImage(String value) {
    _user.profileImage = value;
  }

  set city(String value) {
    _user.city = value;
  }

  set connectWith(List<String> values) {
    _user.connectWith = values;
  }

  set interests(List<String> values) {
    _user.interests = values;
  }

  /*Future<void> updateUser(User updatedUser) async {
    try {
      await _firestoreService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error updating user data: $e');
    }
  }*/

  Future<void> updateUser(User user) async {
    if (user.id.isEmpty) {
      if (kDebugMode) {
        print('User object: $user');
      }
      throw Exception("Invalid user ID");
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUserData({
    String? bio,
    String? city,
    List<String>? connectWith,
    List<String>? interests,
  }) async {
    try {
      await fetchUserData(); // Fetches the latest user data

      // Add debugging statement here
      if (kDebugMode) {
        print('Attempting to update user data for user: ${_user.toString()}');
      }

      // Check for empty user ID
      if (_user.id.isEmpty) {
        if (kDebugMode) {
          print('User ID is empty. Cannot update user data.');
        }
        return;
      }

      // Update user object
      if (bio != null) _user.bio = bio;
      if (city != null) _user.city = city;
      if (connectWith != null) _user.connectWith = connectWith;
      if (interests != null) _user.interests = interests;

      // Update Firestore data
      await updateUser(_user);
      if (!_disposed) notifyListeners();
    } catch (e) {
      // Error handling: Log the error
      if (kDebugMode) {
        print('Error updating user data in Firestore: $e');
      }
      // Optionally, rethrow the error or handle it as needed
    }
  }

  Future<void> saveUserData() async {
    await updateUser(_user);
  }

  Future<void> updateBio(String bio) async {
    _user = User(
      id: _user.id,
      firstName: _user.firstName,
      lastName: _user.lastName,
      age: _user.age,
      bio: bio,
      mbtiType: _user.mbtiType,
      profileImage: _user.profileImage,
      otherImages: _user.otherImages,
      location: _user.location,
      city: _user.city,
      connectWith: _user.connectWith,
      interests: _user.interests,
    );
    await updateUser(_user);
    if (!_disposed) notifyListeners();
  }

  Future<void> addOtherImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String imageUrl = await _storageService.uploadImageToFirebase(
        _user.id,
        io.File(pickedFile.path),
        _user.otherImages?.length ?? 0,
      );
      _user.otherImages ??= [];
      _user.otherImages!.add(imageUrl);
      await _firestoreService.updateUser(_user);
      if (!_disposed) notifyListeners();
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  String get locationMessage =>
      "Location: Lat=${_currentLocation?.latitude}, Long=${_currentLocation?.longitude}";

  removeProfilePicture(BuildContext context) {
    user.profileImage = null;
    notifyListeners();
  }

  Future<void> removeImage(String imageUrl) async {
    try {
      // Logic to remove the image from Firebase Storage
      await _storageService.removeImage(imageUrl);

      // Remove the image URL from the user's profile
      _user.otherImages?.remove(imageUrl);

      // Update the user's data in Firestore
      await _firestoreService.updateUser(_user);

      // Notify any listeners to update the UI
      if (!_disposed) notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing image: $e');
      }
      // Optionally, handle the error (e.g., show an error message to the user)
    }
  }
}
