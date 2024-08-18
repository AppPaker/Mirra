import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/presentation/screens/businesses/businesses.dart';

class NearbyModel {
  final CollectionReference businessesCollection =
      FirebaseFirestore.instance.collection('businesses');
  List<Business> allBusinesses = [
    Business.testData(
      id: '1',
      name: 'Cafe Delight',
      amenity: 'Cafe',
      description: 'A cozy cafe with a variety of beverages.',
      address: '123 Coffee St, Brewtown',
      latitude: 40.7128,
      longitude: -74.0060,
      imageUrls: [
        'https://images.unsplash.com/photo-1511920170033-f8396924c348?fit=crop&w=500&h=500',
        'https://images.unsplash.com/photo-1551615593-ef5fe247e8f7?fit=crop&w=500&h=500',
      ],
      email: "",
      website: 'https://cafedelight.com',
      cuisine: 'Coffee, Tea',
      isVerified: true,
    ),
    Business.testData(
      id: '2',
      name: 'Burger Bliss',
      amenity: 'Restaurant',
      description: 'The best burgers in town.',
      address: '456 Burger Ln, Tastytown',
      latitude: 40.7139,
      longitude: -74.0071,
      imageUrls: [
        'https://images.unsplash.com/photo-1551615593-ef5fe247e8f7?fit=crop&w=500&h=500',
      ],
      website: 'https://burgerbliss.com',
      email: '',
      cuisine: 'Burgers',
      isVerified: true,
    ),
    // Add more test businesses as needed
  ];

  List<Business> filteredBusinesses = [];

  NearbyModel._(); // Private constructor

  static Future<NearbyModel> createInstance(Position userPosition) async {
    NearbyModel model = NearbyModel._();
    await model._fetchBusinessesFromFirestore();
    await model.calculateAndSortBusinessesByDistance(userPosition);
    model.filteredBusinesses = model.allBusinesses;
    return model;
  }

  Future<void> _fetchBusinessesFromFirestore() async {
    QuerySnapshot snapshot = await businessesCollection.get();
    if (snapshot.docs.isNotEmpty) {
      allBusinesses.addAll(snapshot.docs
          .map((doc) => Business.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
    }
  }

  NearbyModel() {
    // Initially, display all businesses
    filteredBusinesses = allBusinesses;
    //calculateDistancesFromUser();
  }

  /*Future<void> calculateDistancesFromUser() async {
    geo.Position userPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);

    for (Business business in allBusinesses) {
      double distanceInMeters = geo.Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        business.latitude,
        business.longitude,
      );

      // Convert distance to kilometers
      business.distanceFromUser = distanceInMeters / 1000;
    }
  }*/

  void filterBusinesses(String query) {
    // Logic to filter businesses based on the query
    filteredBusinesses = allBusinesses.where((business) {
      return business.name.contains(query) ||
          business.amenity.contains(query) ||
          business.address.contains(query) ||
          (business.cuisine != null && business.cuisine!.contains(query));
    }).toList();
  }

  Future<void> calculateAndSortBusinessesByDistance(
      Position userPosition) async {
    for (var business in allBusinesses) {
      // Provide default values if coordinates are null
      double businessLatitude = business.latitude ?? 0.0;
      double businessLongitude = business.longitude ?? 0.0;

      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        businessLatitude,
        businessLongitude,
      );
      business.distanceFromUser = distanceInMeters / 1000; // Convert to km
    }

    allBusinesses.sort((a, b) {
      double distanceA = a.distanceFromUser ?? double.maxFinite;
      double distanceB = b.distanceFromUser ?? double.maxFinite;
      return distanceA.compareTo(distanceB);
    });
  }

// TODO: Add logic to fetch businesses, calculate distances, etc.
}
