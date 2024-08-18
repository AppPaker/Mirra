import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';

import 'firestore_service.dart';

class MockFirestoreService implements FirestoreService {
  @override
  Future<User> getUser(String id) async {
    return User(
      id: 'testId',
      firstName: 'Test',
      lastName: 'User',
      age: 25,
      mbtiType: 'INTJ',
      profileImage: 'https://example.com/profile.jpg',
      bio: 'This is a test bio',
      location: '',
    );
  }

  @override
  Future<List<User>> getAllUsers() async {
    return [
      User(
        id: 'testId1',
        firstName: 'John',
        lastName: 'Doe',
        age: 28,
        mbtiType: 'INFJ',
        profileImage:
            'https://images.unsplash.com/photo-1542103749-8ef59b94f47e',
        bio: 'This is a test bio for John',
        location: '',
      ),
      User(
        id: 'testId2',
        firstName: 'Jane',
        lastName: 'Doe',
        age: 26,
        mbtiType: 'ENFJ',
        profileImage:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
        bio: 'This is a test bio for Jane',
        location: '',
      ),
    ];
  }

  @override
  Future<List<Business>> getAllBusinesses() async {
    return [
      Business(
        id: 'businessId1',
        name: 'Cinema X',
        amenity: 'Entertainment',
        description: 'A popular cinema in the city.',
        address: '123 Street, City',
        latitude: 40.7128, // Example lat and lon values
        longitude: -74.0060,
        imageUrls: [
          '',
        ],
        website: 'http://www.cinemax.com',
        email: '',
        isVerified: true,
      ),
      Business(
        id: 'businessId2',
        name: 'Burger Shack',
        amenity: 'Food',
        description: 'The best burger joint in the town.',
        address: '456 Avenue, City',
        latitude: 40.7150,
        longitude: -74.0085,
        imageUrls: [
          '',
        ],
        website: 'http://www.burgershack.com',
        email: '',
        isVerified: true,
      ),
      Business(
        id: 'businessId3',
        name: 'Tech Store',
        amenity: 'Retail',
        description: 'Your one-stop shop for all tech gadgets.',
        address: '789 Boulevard, City',
        latitude: 40.7172,
        longitude: -74.0111,
        imageUrls: [
          '',
        ],
        website: 'http://www.techstore.com',
        email: '',
        isVerified: true,
      ),
    ];
  }

  @override
  Future<List<Business>> getLocalBusinesses(String location) async {
    return [
      Business(
        id: 'businessId1',
        name: 'Cinema X',
        amenity: 'Entertainment',
        description: 'A popular cinema in the city.',
        address: '123 Street, City',
        latitude: 40.7128, // Example lat and lon values
        longitude: -74.0060,
        imageUrls: [
          '',
        ],
        website: 'http://www.cinemax.com',
        email: '',
        isVerified: true,
      ),
      Business(
        id: 'businessId2',
        name: 'Burger Shack',
        amenity: 'Food',
        description: 'The best burger joint in the town.',
        address: '456 Avenue, City',
        latitude: 40.7150,
        longitude: -74.0085,
        imageUrls: [
          '',
        ],
        website: 'http://www.burgershack.com',
        email: '',
        isVerified: true,
      ),
      Business(
        id: 'businessId3',
        name: 'Tech Store',
        amenity: 'Retail',
        description: 'Your one-stop shop for all tech gadgets.',
        address: '789 Boulevard, City',
        latitude: 40.7172,
        longitude: -74.0111,
        imageUrls: [
          '',
        ],
        website: 'http://www.techstore.com',
        email: '',
        isVerified: true,
      ),
    ];
  }

  @override
  Future<void> updateUser(User user) async {}

  @override
  Future<void> setOnboardingCompleted(String userId) async {}

  @override
  Future<bool> hasCompletedOnboarding(String userId) async => false;
}
