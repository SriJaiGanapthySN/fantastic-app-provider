import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_completed';

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Mark onboarding as completed
  static Future<void> setOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
      print('Onboarding marked as complete');
    } catch (e) {
      print('Error setting onboarding complete: $e');
    }
  }

  /// Reset onboarding status (useful for testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompleteKey);
      print('Onboarding status reset');
    } catch (e) {
      print('Error resetting onboarding: $e');
    }
  }

  /// Clear onboarding status when user logs out
  static Future<void> clearOnboardingOnLogout() async {
    await resetOnboarding();
  }
}
