import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/business_firestore_service.dart';

import '../../app/presentation/screens/users/user.dart';
import '../../app/controllers/users/user_service.dart';
import '../../app/presentation/screens/track_a_date/class.dart';

class DateTrackerViewModel {
  final DateTracker _dateTracker;
  UserService userService = UserService();
  String? _dateDocId;
  Location location = Location();

  DateTrackerViewModel(this._dateTracker);

  void setDateDocId(String id) {
    _dateDocId = id;
  }

  Future<DocumentReference> startTracking(DateTime startTime,
      Business selectedBusiness, User? matchedUser) async {
    _dateTracker.startTime = startTime;
    _dateTracker.active = true;

    String? userId = await userService.getCurrentUserId();
    if (userId != null) {
      Map<String, dynamic> matchData = {};
      if (matchedUser != null) {
        matchData = {
          'id': matchedUser.id,
          'firstName': matchedUser.firstName,
          // Add other required fields of matchedUser
        };
      }

      // Check if the selected business exists in Firestore
      var businessService =
      BusinessFirestoreService(); // Assuming you have this service
      bool businessExists = await businessService.businessExists(
          selectedBusiness.placeId,
          selectedBusiness.name,
          selectedBusiness.address);

      // If the business does not exist, add it to Firestore
      if (!businessExists) {
        await businessService.addBusinessToFirestore(selectedBusiness);
      }

      // Continue with adding the date to the user
      DocumentReference docRef = await userService.addDateToUser(
        userId: userId,
        started: _dateTracker.startTime,
        finished: null,
        locationName: selectedBusiness.name,
        locationAddress: selectedBusiness.address,
        active: _dateTracker.active,
        trustedContactEmail: _dateTracker.trustedContactEmail,
        matchData: matchData,
      );
      _dateDocId = docRef.id;
      return docRef;
    }
    throw Exception('User ID is null');
  }

  Stream<List<Business>> searchBusinesses(String query, double latitude,
      double longitude) async* {
    if (query.isEmpty) {
      yield []; // Return an empty list if the search query is empty
      return;
    }
    var firestoreResults = FirebaseFirestore.instance
        .collection('businesses')
        .where('name_lowercase', isEqualTo: query.toLowerCase())
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Business.fromMap(doc.data())).toList());

    await for (var businesses in firestoreResults) {
      if (kDebugMode) {
        print('Firestore Query Result: $businesses');
      } // Debug log
      if (businesses.isNotEmpty) {
        yield businesses;
      } else {
        // Fetch from Google Places
        try {
          var googlePlacesResults =
          await searchBusinessesInGooglePlaces(query, latitude, longitude);
          if (kDebugMode) {
            print('Businesses from Google Places: $googlePlacesResults');
          } // Debug log

          yield googlePlacesResults;
        } catch (e) {
          yield [];
        }
      }
    }
  }

  Future<List<Business>> searchBusinessesInGooglePlaces(String query,
      double latitude, double longitude) async {
    const String apiKey = 'AIzaSyA41lWIEftHYJ1vxc8aLLavrs3ZGxv90p0';
    const String endpoint =
        'https://places.googleapis.com/v1/places:searchText';

    final String locationBias = json.encode({
      'circle': {
        'center': {'latitude': latitude, 'longitude': longitude},
        'radius': 5000
      }
    });

    final Uri uri = Uri.parse(endpoint);
    final Map<String, dynamic> requestBody = {
      'textQuery': query,
      'locationBias': json.decode(locationBias),
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
          'places.displayName,places.formattedAddress,places.types,places.id'
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          print("Full API Response: $data");
        }
        if (data['places'] != null) {
          List<Business> businesses = (data['places'] as List).map((result) {
            Business business = Business.fromGooglePlaces(result);
            if (kDebugMode) {
              print(
                  "Parsed Business: Name - ${business
                      .name}, Address - ${business
                      .address}, PlaceId - ${business.placeId}");
            }
            if (kDebugMode) {
              print("Place ID: ${business.placeId}");
            }

            return business;
          }).toList();
          return businesses;
        }
      } else {
        if (kDebugMode) {
          print('HTTP Error: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    return [];
  }

  Future<void> updateCurrentLocation(LocationData locationData,
      DateTime updateTime) async {
    String? userId = await userService.getCurrentUserId();
    if (userId != null && _dateDocId != null) {
      await userService.updateDateLocation(
        userId: userId,
        dateDocId: _dateDocId!,
        locationData: locationData,
      );
    }
    // Logic to update location in Firestore
  }

  Future<LocationData?> getCurrentLocation() async {
    LocationData? currentLocation;
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return null;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<void> updateLocationInFirestore(String newLocation) async {
    String? userId = await userService.getCurrentUserId();
    if (_dateDocId != null && userId != null) {
      await userService.updateLocationInFirestore(
          _dateDocId!, newLocation, userId);
    }
  }

  void setTrustedContactEmail(String email) {
    _dateTracker.trustedContactEmail = email;
    // Additional logic for setting trusted contact
  }

  void setDateTrackerSelectedMatch(User match) {
    _dateTracker.selectedMatch = match;
  }

  Future<void> stopTracking(DateTime stopTime) async {
    _dateTracker.endTime = stopTime;
    _dateTracker.active = false;

    String? userId = await userService.getCurrentUserId();
    if (userId != null && _dateDocId != null) {
      // Update the existing document in the 'dates' subcollection
      await userService.updateDateForUser(
        userId: userId,
        dateDocId: _dateDocId!,
        finished: _dateTracker.endTime!,
        active: _dateTracker.active,
      );
    }
    // Reset the _dateDocId to null after stopping the tracking
    _dateDocId = null;
    // Additional logic to handle stop tracking
  }

  Future<List<User>> fetchMatchedUsers() async {
    return await userService.fetchMatchedUsers();
  }

// Add other methods as needed for functionalities like notifying trusted contact
}
