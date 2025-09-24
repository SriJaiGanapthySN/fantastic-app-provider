import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_service.dart';

// Provider for the current auth token
final authTokenProvider = FutureProvider<String?>((ref) async {
  return await TokenService.getValidToken();
});

// Provider for token validation status
final tokenValidationProvider = FutureProvider<bool>((ref) async {
  return await TokenService.validateToken();
});

// Provider for user data from token service
final tokenUserDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await TokenService.getAllUserData();
});

// Synchronous provider for cached token (use carefully)
final cachedTokenProvider = Provider<String?>((ref) {
  // This should only be used when you're sure the token is already cached
  // For most cases, use authTokenProvider instead
  return null; // Will be updated by TokenService when available
});

// Provider to check if user is authenticated based on token
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  return await TokenService.isAuthenticated();
});

// Provider for token expiry information
final tokenExpiryProvider = FutureProvider<DateTime?>((ref) async {
  return await TokenService.getTokenExpiry();
});

// Provider to check if token needs refresh
final tokenNeedsRefreshProvider = FutureProvider<bool>((ref) async {
  return await TokenService.needsRefresh();
});

// Helper function to get valid token from anywhere
Future<String?> getValidToken(WidgetRef ref) async {
  final tokenAsync = await ref.read(authTokenProvider.future);
  return tokenAsync;
}

// Helper function to check authentication status
Future<bool> isUserAuthenticated(WidgetRef ref) async {
  final authAsync = await ref.read(isAuthenticatedProvider.future);
  return authAsync;
}

// Helper function to get user data
Future<Map<String, dynamic>> getUserData(WidgetRef ref) async {
  final userDataAsync = await ref.read(tokenUserDataProvider.future);
  return userDataAsync;
}
