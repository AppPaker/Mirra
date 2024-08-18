import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingModel extends ChangeNotifier {
  bool _hasCompletedOnboarding = false;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // Load onboarding status
  Future<void> loadOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    notifyListeners();
  }

  // Complete the onboarding
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;

    // Save to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasCompletedOnboarding', true);

    notifyListeners();
  }
}
