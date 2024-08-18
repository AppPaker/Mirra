import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';

class FirestoreService {
  Future<User> getUser(String id) {
    throw UnimplementedError();
  }

  Future<void> updateUser(User user) {
    throw UnimplementedError();
  }

  Future<List<User>> getAllUsers() {
    throw UnimplementedError();
  }

  Future<List<Business>> getAllBusinesses() {
    throw UnimplementedError();
  }

  Future<List<Business>> getLocalBusinesses(String location) {
    throw UnimplementedError();
  }

  Future<void> setOnboardingCompleted(String userId) {
    throw UnimplementedError();
  }

  Future<bool> hasCompletedOnboarding(String userId) {
    throw UnimplementedError();
  }
}
