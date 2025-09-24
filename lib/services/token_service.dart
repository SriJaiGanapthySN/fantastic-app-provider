import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TokenService {
  static const String _tokenKey = 'access_token';
  static const String _firebaseTokenKey = 'firebase_token';
  static const String _backendTokenKey = 'backend_api_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _passwordKey = 'user_password'; // For backend auth

  // Cache variables to avoid repeated SharedPreferences calls
  static String? _cachedToken;
  static String? _cachedFirebaseToken;
  static String? _cachedBackendToken;
  static String? _cachedEmail;
  static String? _cachedName;
  static String? _cachedUserId;
  static String? _cachedPassword;
  static DateTime? _cachedTokenExpiry;
  static bool _cacheInitialized = false;

  // Firebase Auth instance
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream subscription for Firebase auth state changes
  static StreamSubscription<User?>? _authStateSubscription;

  // Initialize Firebase Auth state listener
  static void initializeFirebaseAuthListener() {
    _authStateSubscription?.cancel(); // Cancel any existing subscription

    _authStateSubscription =
        _firebaseAuth.authStateChanges().listen((User? user) async {
      print('🔥 Firebase Auth State Changed: ${user?.uid ?? 'null'}');

      if (user != null) {
        // User is signed in, refresh token
        print('🔄 User signed in, refreshing token...');
        await generateAndStoreToken();
        await storeUserDetails(
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          userId: user.uid,
        );
      } else {
        // User is signed out, clear tokens
        print('🚪 User signed out, clearing tokens...');
        await clearAllData();
      }
    });

    print('🎧 Firebase Auth state listener initialized');
  }

  // Dispose Firebase Auth listener
  static void disposeFirebaseAuthListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    print('🔇 Firebase Auth state listener disposed');
  }

  // Initialize cache from SharedPreferences
  static Future<void> _initializeCache() async {
    if (_cacheInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    _cachedFirebaseToken = prefs.getString(_firebaseTokenKey);
    _cachedBackendToken = prefs.getString(_backendTokenKey);
    _cachedEmail = prefs.getString(_userEmailKey);
    _cachedName = prefs.getString(_userNameKey);
    _cachedUserId = prefs.getString(_userIdKey);
    _cachedPassword = prefs.getString(_passwordKey);

    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);
    if (expiryTimestamp != null) {
      _cachedTokenExpiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    }

    _cacheInitialized = true;
    print('💾 Token cache initialized');
  }

  // Generate and store backend API token using email/password or Firebase token
  static Future<String?> generateAndStoreBackendToken() async {
    try {
      await _initializeCache();

      // First try email/password authentication for traditional login
      if (_cachedEmail != null &&
          _cachedPassword != null &&
          _cachedPassword!.isNotEmpty) {
        print(
            '🔄 Getting backend API token using email/password for: ${_cachedEmail}');

        const baseUrl = 'https://mental-health.rohanrichard.com';
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/token'),
              headers: {
                'accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'email': _cachedEmail,
                'password': _cachedPassword,
              }),
            )
            .timeout(Duration(seconds: 30));

        print(
            '🔐 Backend auth (email/password) response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final backendToken = data['access_token'];

          if (backendToken != null) {
            await _storeBackendToken(backendToken);
            print('✅ Backend API token generated using email/password');
            return backendToken;
          }
        } else {
          print('❌ Backend authentication failed: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }

      // If email/password failed or not available, try Firebase token authentication
      print('🔄 Attempting Firebase token authentication for backend...');
      final firebaseToken = await getValidToken();

      if (firebaseToken != null && _cachedEmail != null) {
        print(
            '🔄 Using Firebase ID token for backend authentication: ${_cachedEmail}');

        const baseUrl = 'https://mental-health.rohanrichard.com';
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/firebase-auth'),
              headers: {
                'accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $firebaseToken',
              },
              body: jsonEncode({
                'email': _cachedEmail,
              }),
            )
            .timeout(Duration(seconds: 30));

        print(
            '🔐 Backend auth (Firebase) response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final backendToken = data['access_token'];

          if (backendToken != null) {
            await _storeBackendToken(backendToken);
            print('✅ Backend API token generated using Firebase token');
            return backendToken;
          }
        } else {
          print(
              '❌ Backend Firebase authentication failed: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }

      print('❌ No valid authentication method available for backend');
      return null;
    } catch (e) {
      print('💥 Error generating backend API token: $e');
      return null;
    }
  }

  // Store backend API token
  static Future<void> _storeBackendToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendTokenKey, token);
    _cachedBackendToken = token; // Update cache
  }

  // Get backend API token (generates if not exists or expired)
  static Future<String?> getBackendToken() async {
    await _initializeCache();

    // Return cached token if available
    if (_cachedBackendToken != null && _cachedBackendToken!.isNotEmpty) {
      print('✅ Using cached backend API token');
      return _cachedBackendToken;
    }

    // Generate new token if none cached
    print('🔄 No cached backend token, generating new one...');
    return await generateAndStoreBackendToken();
  }

  // Store user password for backend authentication (encrypted in real app)
  static Future<void> storeUserPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
    _cachedPassword = password; // Update cache
  }

  static Future<String?> generateAndStoreToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        print('❌ No authenticated Firebase user found');
        return null;
      }

      // Get Firebase ID token (which is a JWT token)
      final idTokenResult = await user.getIdTokenResult(true); // Force refresh
      final token = idTokenResult.token;
      final expirationTime = idTokenResult.expirationTime;

      if (token != null && expirationTime != null) {
        // Store the token and its expiry
        await storeToken(token);
        await _storeTokenExpiry(expirationTime);

        print('✅ Firebase ID token generated and stored successfully');
        print('⏰ Token expires at: $expirationTime');

        return token;
      } else {
        print('❌ Failed to generate Firebase ID token');
        return null;
      }
    } catch (e) {
      print('💥 Error generating Firebase auth token: $e');
      return null;
    }
  }

  // Get current Firebase user information
  static User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  // Check if Firebase user is authenticated
  static bool isFirebaseUserAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  // Force Firebase token refresh
  static Future<String?> refreshFirebaseToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        print('❌ No Firebase user to refresh token for');
        return null;
      }

      print('🔄 Force refreshing Firebase ID token...');
      final idTokenResult = await user.getIdTokenResult(true); // Force refresh
      final token = idTokenResult.token;
      final expirationTime = idTokenResult.expirationTime;

      if (token != null && expirationTime != null) {
        await storeToken(token);
        await _storeTokenExpiry(expirationTime);

        print('✅ Firebase token refreshed successfully');
        return token;
      }

      return null;
    } catch (e) {
      print('💥 Error refreshing Firebase token: $e');
      return null;
    }
  }

  // Store authentication token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _cachedToken = token; // Update cache
  }

  // Store token expiry time
  static Future<void> _storeTokenExpiry(DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);
    _cachedTokenExpiry = expiry; // Update cache
  }

  // Get stored token (with caching)
  static Future<String?> getToken() async {
    await _initializeCache();
    return _cachedToken;
  }

  // Get valid token (refreshes if expired, syncs with Firebase)
  static Future<String?> getValidToken() async {
    await _initializeCache();

    // First check if Firebase user is authenticated
    if (!isFirebaseUserAuthenticated()) {
      print('❌ No Firebase user authenticated');
      await clearAllData();
      return null;
    }

    // Check if token exists and is not expired
    if (_cachedToken != null && _cachedTokenExpiry != null) {
      final now = DateTime.now();

      // If token expires within next 5 minutes, refresh it
      if (_cachedTokenExpiry!.isAfter(now.add(Duration(minutes: 5)))) {
        print('✅ Using cached valid Firebase token');
        return _cachedToken;
      } else {
        print('⏰ Firebase token expired or expiring soon, refreshing...');
        // Token is expired or expiring soon, refresh it
        return await refreshFirebaseToken();
      }
    } else {
      print('🔄 No cached token found, generating new Firebase token...');
      // No token or expiry found, generate new one
      return await generateAndStoreToken();
    }
  }

  // Store user details
  static Future<void> storeUserDetails({
    required String email,
    String? name,
    String? userId,
    String? password, // For backend authentication
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    _cachedEmail = email; // Update cache

    if (name != null) {
      await prefs.setString(_userNameKey, name);
      _cachedName = name; // Update cache
    }

    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
      _cachedUserId = userId; // Update cache
    }

    if (password != null) {
      await prefs.setString(_passwordKey, password);
      _cachedPassword = password; // Update cache
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

  // Get stored user ID (with caching)
  static Future<String?> getUserId() async {
    await _initializeCache();
    return _cachedUserId;
  }

  // Check if user is authenticated with valid token and Firebase
  static Future<bool> isAuthenticated() async {
    await _initializeCache();

    // First check Firebase auth state
    if (!isFirebaseUserAuthenticated()) {
      print('❌ Firebase user not authenticated');
      return false;
    }

    if (_cachedToken == null || _cachedToken!.isEmpty) {
      print('❌ No cached token found');
      return false;
    }

    // Check if token is expired
    if (_cachedTokenExpiry != null) {
      final now = DateTime.now();
      if (_cachedTokenExpiry!.isBefore(now)) {
        print('⏰ Token has expired');
        return false;
      }
    }

    print('✅ User is authenticated with valid Firebase token');
    return true;
  }

  // Validate token by checking Firebase auth state and token validity
  static Future<bool> validateToken() async {
    await _initializeCache();

    // First check if we have a token and it's not expired
    if (!await isAuthenticated()) {
      return false;
    }

    try {
      // Check if Firebase user is still authenticated
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        print('❌ No Firebase user found, token invalid');
        await clearAllData();
        return false;
      }

      // Try to refresh the token to verify it's still valid
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        print('❌ Firebase user session expired, token invalid');
        await clearAllData();
        return false;
      }

      // Verify the token is still valid by getting a fresh one
      try {
        final idTokenResult = await refreshedUser.getIdTokenResult();
        if (idTokenResult.token == null) {
          print('❌ Firebase ID token is null, session invalid');
          await clearAllData();
          return false;
        }
      } catch (e) {
        print('💥 Error getting Firebase ID token: $e');
        await clearAllData();
        return false;
      }

      print('✅ Firebase token validation successful');
      return true;
    } catch (e) {
      print('💥 Error validating Firebase token: $e');
      await clearAllData();
      return false;
    }
  }

  // Get token expiry time
  static Future<DateTime?> getTokenExpiry() async {
    await _initializeCache();
    return _cachedTokenExpiry;
  }

  // Check if token needs refresh (expires within specified minutes)
  static Future<bool> needsRefresh({int minutesBeforeExpiry = 5}) async {
    await _initializeCache();

    if (_cachedTokenExpiry == null) {
      return true; // No expiry means we need to refresh
    }

    final now = DateTime.now();
    final expiryThreshold = now.add(Duration(minutes: minutesBeforeExpiry));

    return _cachedTokenExpiry!.isBefore(expiryThreshold);
  }

  // Clear all stored data (logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_firebaseTokenKey);
    await prefs.remove(_backendTokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_tokenExpiryKey);

    // Clear cache
    _cachedToken = null;
    _cachedFirebaseToken = null;
    _cachedBackendToken = null;
    _cachedEmail = null;
    _cachedName = null;
    _cachedUserId = null;
    _cachedPassword = null;
    _cachedTokenExpiry = null;
    _cacheInitialized = false;

    print('🧹 All token data cleared');
  }

  // Force refresh cache (useful after external changes)
  static Future<void> refreshCache() async {
    _cacheInitialized = false;
    await _initializeCache();
    print('🔄 Token cache refreshed');
  }

  // Get all user data as a map (includes Firebase state)
  static Future<Map<String, dynamic>> getAllUserData() async {
    await _initializeCache();

    final firebaseUser = getCurrentFirebaseUser();

    return {
      'token': _cachedToken,
      'email': _cachedEmail,
      'name': _cachedName,
      'userId': _cachedUserId,
      'tokenExpiry': _cachedTokenExpiry?.toIso8601String(),
      'isAuthenticated': await isAuthenticated(),
      'firebaseUser': firebaseUser != null
          ? {
              'uid': firebaseUser.uid,
              'email': firebaseUser.email,
              'displayName': firebaseUser.displayName,
              'emailVerified': firebaseUser.emailVerified,
            }
          : null,
      'firebaseAuthState': isFirebaseUserAuthenticated(),
    };
  }

  // Sync with Firebase auth state (call this when Firebase state changes)
  static Future<void> syncWithFirebaseAuth() async {
    final user = getCurrentFirebaseUser();

    if (user != null) {
      // User is authenticated, ensure we have a valid token
      final token = await generateAndStoreToken();
      if (token != null) {
        await storeUserDetails(
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          userId: user.uid,
        );
        print('🔄 Synced with Firebase auth - token updated');
      }
    } else {
      // User is not authenticated, clear all data
      await clearAllData();
      print('🔄 Synced with Firebase auth - data cleared');
    }
  }
}
