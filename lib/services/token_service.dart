import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'access_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  // Cache variables to avoid repeated SharedPreferences calls
  static String? _cachedToken;
  static String? _cachedEmail;
  static String? _cachedName;
  static bool _cacheInitialized = false;

  // Initialize cache from SharedPreferences
  static Future<void> _initializeCache() async {
    if (_cacheInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    _cachedEmail = prefs.getString(_userEmailKey);
    _cachedName = prefs.getString(_userNameKey);
    _cacheInitialized = true;
  }

  // Store authentication token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _cachedToken = token; // Update cache
  }

  // Get stored token (with caching)
  static Future<String?> getToken() async {
    await _initializeCache();
    return _cachedToken;
  }

  // Store user details
  static Future<void> storeUserDetails({
    required String email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    _cachedEmail = email; // Update cache

    if (name != null) {
      await prefs.setString(_userNameKey, name);
      _cachedName = name; // Update cache
    }
  }

  // Get stored user email (with caching)
  static Future<String?> getUserEmail() async {
    await _initializeCache();
    return _cachedEmail;
  }

  // Get stored user name (with caching)
  static Future<String?> getUserName() async {
    await _initializeCache();
    return _cachedName;
  }

  // Check if user is authenticated (with caching)
  static Future<bool> isAuthenticated() async {
    await _initializeCache();
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }

  // Clear all stored data (logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);

    // Clear cache
    _cachedToken = null;
    _cachedEmail = null;
    _cachedName = null;
    _cacheInitialized = false;
  }

  // Validate token by checking if it exists and is not empty (with caching)
  static Future<bool> validateToken() async {
    await _initializeCache();
    if (_cachedToken == null || _cachedToken!.isEmpty) {
      return false;
    }

    // Additional validation can be added here
    // For example, checking token expiration, making API call to validate, etc.

    return true;
  }

  // Force refresh cache (useful after external changes)
  static Future<void> refreshCache() async {
    _cacheInitialized = false;
    await _initializeCache();
  }
}
