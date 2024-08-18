import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../businesses/businesses.dart';

const List<String> supportedPlaceTypes = [
  'bar',
  'cafe',
  'restaurant',
  'night_club',
  'movie_theater',
  'art_gallery',
  'amusement_park',
  'bakery',
  'bicycle_store',
  'book_store',
  'bowling_alley',
  'casino',
  'department_store',
  'gym',
  'jewelry_store',
  'zoo',
  'university',
  'train_station',
  'tourist_attraction',
  'stadium',
  'spa',
  'shopping_mall',
  'shoe_store',
  'pet_store',
  'park',
  'museum',
  'meal_takeaway',
  'meal_delivery',
  'library',

  // ... add more types as needed
];

Future<List<Business>> fetchBusinessesForMap() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Fetch businesses from Firestore
  List<Business> firestoreBusinesses =
      await firestore.collection('businesses').get().then((querySnapshot) {
    return querySnapshot.docs
        .map((doc) => Business.fromMap(doc.data()))
        .toList();
  });

  List<Business> businessesForMap = [];

  for (var business in firestoreBusinesses) {
    if (business.address.isNotEmpty) {
      // Use Google Places API to get accurate location details based on business address
      try {
        var locationDetails = await getGooglePlacesDetails(business.address);
        business.latitude = locationDetails.latitude;
        business.longitude = locationDetails.longitude;
        businessesForMap.add(business);
      } catch (e) {
        if (kDebugMode) {
          print(
              "Error fetching location for business: ${business.name}. Error: $e");
        }
      }
    } else {
      // Handle businesses without addresses (maybe skip them or provide a default location)
      if (kDebugMode) {
        print("Business ${business.name} does not have an address.");
      }
    }
  }

  // 3. Return the combined list of businesses
  return businessesForMap;
}

// This is a pseudo-function to get details from Google Places API based on business address or name
Future<dynamic> getGooglePlacesDetails(String address) async {
  const apiKey = 'AIzaSyC-RQS9nE4yVQLyYjNeq6zoBDd4JtpKHdg';
  const baseUrl =
      'https://maps.googleapis.com/maps/api/place/findplacefromtext/json';

  // Here's the URL encoding part
  String encodedAddress = Uri.encodeComponent(address);

  // Use the encoded address in your URL
  String url =
      '$baseUrl?input=$encodedAddress&inputtype=textquery&fields=place_id,name,geometry&key=$apiKey';

  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    if (data['candidates'] != null && data['candidates'].length > 0) {
      return {
        'latitude': data['candidates'][0]['geometry']['location']['lat'],
        'longitude': data['candidates'][0]['geometry']['location']['lng']
      };
    } else {
      if (kDebugMode) {
        print("No candidates found. Response: ${response.body}");
      }
      throw Exception('Failed to fetch data from Google Places API');
    }
  } else {
    if (kDebugMode) {
      print(
          "Error status code: ${response.statusCode}. Response: ${response.body}");
    }
    throw Exception('Failed to fetch data from Google Places API');
  }
}
