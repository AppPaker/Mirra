import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

class Business {
  final String id;
  final String name;
  final String amenity;
  final String description;
  final String address;
  late final double? latitude; // Made this optional
  late final double? longitude; // Made this optional
  List<String> imageUrls;
  final String website;
  final String email;
  final String? cuisine;
  double? distanceFromUser;
  final bool isVerified;
  final String? placeId;

  Business({
    required this.id,
    required this.name,
    required this.amenity,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.imageUrls,
    required this.website,
    required this.email,
    this.cuisine,
    this.distanceFromUser,
    required this.isVerified,
    this.placeId,
  });

  Business.testData({
    required this.id,
    required this.name,
    required this.amenity,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.website,
    required this.email,
    this.cuisine,
    this.distanceFromUser,
    required this.isVerified,
    this.placeId,
  });

  factory Business.fromMap(Map<String, dynamic> data) {
    return Business(
      id: data['id'] ?? '',
      // Default to an empty string if id is null
      name: data['name'] ?? '',
      // Default to an empty string if name is null
      amenity: data['amenity'] ?? '',
      // Default to an empty string if amenity is null
      description: data['description'] ?? '',
      // Default to an empty string if description is null
      address: data['address'] ?? '',
      // Default to an empty string if address is null
      latitude: data['latitude'] as double?,
      // Keep as nullable double
      longitude: data['longitude'] as double?,
      // Keep as nullable double
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      // Default to an empty list if imageUrls is null
      website: data['website'] ?? '',
      // Default to an empty string if website is null
      email: data['email'] ?? '',
      // Default to an empty string if email is null
      cuisine: data['cuisine'] ?? '',
      // Default to an empty string if cuisine is null
      isVerified: data['isVerified'] ?? false,
      placeId: data['placeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amenity': amenity,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'website': website,
      'email': email,
      'cuisine': cuisine,
      'isVerified': isVerified,
      'placeId': placeId,
    };
  }

  factory Business.fromGooglePlaces(Map<String, dynamic> data) {
    String name = data['displayName']?['text'] ?? 'Unknown Name';
    String address = data['formattedAddress'] ?? 'Unknown Address';
    String placeId = data['id'] ?? '';

    return Business(
      id: placeId, // Use place_id as the id

      name: name,
      address: address,
      latitude: null, // Update logic to extract latitude if available
      longitude: null, // Update logic to extract longitude if available
      amenity: '', // Update logic to extract amenity if available
      description: '', // Set a default or extract if available
      imageUrls: [], // Set a default or extract if available
      website: '', // Set a default or extract if available
      email: '', // Set a default or extract if available
      cuisine: '', // Set a default or extract if available
      distanceFromUser: null, // Set a default or extract if available
      isVerified: false, // Set a default or extract if available
      placeId: placeId, // Adjust if 'place_id' field differs in new API
    );
  }

  factory Business.fromPickResult(PickResult pickResult) {
    return Business(
      id: pickResult.placeId ?? '',
      // Default to an empty string if placeId is null
      name: pickResult.formattedAddress ?? 'Unknown Name',
      // Default value if null
      address: pickResult.formattedAddress ?? 'Unknown Address',
      // Default value if null
      latitude: pickResult.geometry?.location.lat,
      longitude: pickResult.geometry?.location.lng,
      // Set other fields with default values or based on what's available in PickResult
      amenity: '',
      description: '',
      imageUrls: [],
      website: '',
      email: '',
      cuisine: '',
      distanceFromUser: null,
      isVerified: false,
    );
  }
}
