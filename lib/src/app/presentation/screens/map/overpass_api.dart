import 'dart:convert';

import 'package:http/http.dart' as http;

import '../businesses/businesses.dart';

/*const List<String> supportedAmenities = [
  'bar',
  'biergarten',
  'cafe',
  'fast_food',
  'food_court',
  'ice_cream',
  'pub',
  'restaurant',
  'arts_centre',
  'casino',
  'cinema',
  'community_centre',
  'conference_centre',
  'events_venue',
  'exhibition_centre',
  'music_venue',
  'nightclub',
  'planetarium',
  'public_bookcase',
  'social_centre',
  'studio',
  'theatre'
];*/

Future<List<Business>> fetchBusinessesFromOverpass(
    double lat, double lon, List<String> supportedAmenities) async {
  double delta = 0.01;
  double minLat = lat - delta;
  double minLon = lon - delta;
  double maxLat = lat + delta;
  double maxLon = lon + delta;

  String constructAmenityQuery(List<String> amenities) {
    String nodes = amenities
        .map((amenity) =>
            'node[amenity=$amenity]($minLat,$minLon,$maxLat,$maxLon);')
        .join(' ');
    return '''
    [out:json];
    $nodes
    out;
    ''';
  }

  String query = constructAmenityQuery(supportedAmenities);

  String url = 'https://overpass-api.de/api/interpreter';
  var response = await http.post(Uri.parse(url), body: {'data': query});

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    List<Business> businesses = [];

    for (var element in data['elements']) {
      if (element['type'] == 'node') {
        businesses.add(Business(
            id: element['id'].toString(),
            name: element['tags']['name'] ?? 'Unknown',
            description: element['tags']['note'] ?? 'No description',
            address:
                "${element['tags']['addr:street'] ?? 'Unknown street'}, ${element['tags']['addr:city'] ?? 'Unknown city'}, ${element['tags']['addr:postcode'] ?? 'Unknown postcode'}",
            latitude: element['lat'],
            longitude: element['lon'],
            website: element['tags']['contact:website'] ?? 'No website',
            imageUrls: [
              '',
            ], // You can set a default image URL here if you don't have one from Overpass
            email: element['email'],
            amenity: element['tags']['amenity'] ??
                'Unknown', // Extracting amenity tag
            cuisine: element['tags'][
                'cuisine'], // Extracting cuisine tag if it exists, it will be null if it doesn't
            isVerified: element['isVerified']));
      }
    }

    return businesses;
  } else {
    throw Exception('Failed to fetch data from Overpass API');
  }
}
