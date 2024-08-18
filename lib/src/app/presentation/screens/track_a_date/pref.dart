import 'package:shared_preferences/shared_preferences.dart';

import '../users/user.dart';

Future<void> saveTrackingState(
    String businessName,
    String businessAddress,
    String trustedEmail,
    bool isTracking,
    String dateDocId,
    User? matchedUser) async {
  // Added dateDocId parameter
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('businessName', businessName);
  await prefs.setString('businessAddress', businessAddress);
  await prefs.setString('trustedEmail', trustedEmail);
  await prefs.setBool('isTracking', isTracking);
  await prefs.setString('dateDocId', dateDocId);
  await prefs.setString('matchedUserId', matchedUser?.id ?? '');
  await prefs.setString('matchedUserFirstName', matchedUser?.firstName ?? '');
}

Future<Map<String, dynamic>> restoreTrackingState() async {
  final prefs = await SharedPreferences.getInstance();
  String businessName = prefs.getString('businessName') ?? '';
  String businessAddress = prefs.getString('businessAddress') ?? '';
  String trustedEmail = prefs.getString('trustedEmail') ?? '';
  bool isTracking = prefs.getBool('isTracking') ?? false;
  String dateDocId = prefs.getString('dateDocId') ?? '';
  String matchedUserId = prefs.getString('matchedUserId') ?? '';
  String matchedUserFirstName = prefs.getString('matchedUserFirstName') ?? '';

  return {
    'businessName': businessName,
    'businessAddress': businessAddress,
    'trustedEmail': trustedEmail,
    'isTracking': isTracking,
    'dateDocId': dateDocId,
    'matchedUserId': matchedUserId,
    'matchedUserFirstName': matchedUserFirstName,
  };
}

Future<void> clearTrackingState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('businessName');
  await prefs.remove('businessAddress');
  await prefs.remove('trustedEmail');
  await prefs.remove('isTracking');
  await prefs.remove('dateDocId');
}
