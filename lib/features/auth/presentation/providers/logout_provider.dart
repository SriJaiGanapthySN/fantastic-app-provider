import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chat/data/services/token/token_service.dart';
import '../screens/auth_page.dart';

// Provider for logout functionality
final logoutProvider = Provider<Future<void> Function(BuildContext)>((ref) {
  return (BuildContext context) async {
    try {
      // Clear all stored token and user data
      await TokenService.clearAllData();

      // Navigate to auth page and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Show error message if needed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  };
});

// Simple logout function that can be used anywhere
Future<void> logout(BuildContext context) async {
  try {
    await TokenService.clearAllData();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    }
  } catch (e) {
    print('Error during logout: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
