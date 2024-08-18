import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirra/src/domain/services/navigation_service.dart';

abstract class AuthService {
  Future<String> getUserId();
  Future<void> signInUser(String email, String password);
  String? get currentUserId; // <-- Add this line
  Future<void> logout();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  NavigationService navigationService = NavigationService();

  @override
  String? get currentUserId =>
      _firebaseAuth.currentUser?.uid; // <-- Implement the getter here

  @override
  Future<String> getUserId() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      navigationService.navigateToAuth();
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  @override
  Future<void> signInUser(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await navigationService.navigateToAuth();
  }
}

// Uncomment below if you need the MockAuthService for debugging purposes

/*
class MockAuthService implements AuthService {
  @override
  Future<String> getUserId() async {
    return 'OieY2gsvUubXAv4zIBnOmVHkDto1'; // the user ID you want to use
  }

  @override
  Future<void> signInUser(String email, String password) async {
    // Simulate a delay
    await Future.delayed(Duration(seconds: 1));

    // Optionally, you can throw an error to simulate a failed sign-in
    // throw FirebaseAuthException(code: 'ERROR_WRONG_PASSWORD', message: 'Wrong password provided for that user.');
  }

  @override
  String? get currentUserId => 'OieY2gsvUubXAv4zIBnOmVHkDto1';  // <-- Mocked user ID
}

class CombinedAuthService implements AuthService {
  final AuthService _authService;

  CombinedAuthService._(this._authService);

  factory CombinedAuthService() {
    if (kDebugMode) {
      return CombinedAuthService._(MockAuthService());
    } else {
      return CombinedAuthService._(FirebaseAuthService());
    }
  }

  @override
  Future<String> getUserId() => _authService.getUserId();

  @override
  Future<void> signInUser(String email, String password) => _authService.signInUser(email, password);

  @override
  String? get currentUserId => _authService.currentUserId;
}
*/
