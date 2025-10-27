import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fantastic_app_riverpod/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/app_user.dart';
import '../../../../core/utils/connectivity_helper.dart';
import '../../../chat/data/services/token/token_service.dart';
import '../../../../core/log/app_logger.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> getCurrentUser() async {
    //Get logged in user from firebase.
    final firebaseUser = firebaseAuth.currentUser;

    //No user logged in.
    if (firebaseUser == null) {
      return null;
    }

    //Fetch user document from firestore.
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection("users").doc(firebaseUser.uid).get();

    //Check if user doc exists
    if (!userDoc.exists) {
      return null;
    }

    //User exists - load all profile data
    final data = userDoc.data() as Map<String, dynamic>;
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: data['name'] ?? 'User',
      age: data['age'],
      gender: data['gender'],
      location: data['location'],
      stressLevel: data['stressLevel'],
      profileComplete: data['profileComplete'] ?? false,
    );
  }

  @override
  Future<AppUser?> loginWithEmailAndPassword(
      String email, String password) async {
    // Check connectivity before attempting login
    final hasInternet = await ConnectivityHelper.hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed: No user data returned');
      }

      // Create AppUser instance
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? 'No email',
        name: user.displayName ?? 'User',
      );

      // Generate and store auth token
      await TokenService.generateAndStoreToken();

      // Store user details in TokenService (including password for backend)
      await TokenService.storeUserDetails(
        email: appUser.email,
        name: appUser.name,
        userId: appUser.uid,
        password: password, // Store password for backend API authentication
      );

      // Try to generate backend API token
      // If it fails (user not registered in backend), try to register them
      final backendToken = await TokenService.generateAndStoreBackendToken();

      if (backendToken == null) {
        AppLogger.w(
            '⚠️ Backend token generation failed - user may not be registered in backend');
        AppLogger.i('📝 Attempting to register user in backend...');

        // Try to register the user in backend (using default values for missing fields)
        await _registerUserInBackendAPI(
          appUser.name,
          appUser.email,
          password,
        );

        // Try again to get backend token after registration
        final retryToken = await TokenService.generateAndStoreBackendToken();
        if (retryToken != null) {
          AppLogger.i(
              '✅ Backend token generated successfully after registration');
        } else {
          AppLogger.w(
              '⚠️ Could not generate backend token - chat features may be limited');
        }
      } else {
        AppLogger.i('✅ Backend token generated successfully');
      }

      AppLogger.i('Login successful - Auth token generated and stored');
      return appUser;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _logError('Login Failed', e);
      // Check if it's a network-related error
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('internet') ||
          e.toString().toLowerCase().contains('connection')) {
        throw Exception(
            'Network error. Please check your internet connection and try again.');
      }
      throw Exception('Login Failed: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      // Clear stored tokens and user data first
      await TokenService.clearAllData();

      // Then sign out from Firebase Auth
      await firebaseAuth.signOut();

      // Also sign out from Google to allow account switching
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      }

      print('Logout successful - All tokens and data cleared');
    } catch (e) {
      _logError('Error during logout', e);
      throw Exception('Logout Failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> signupWithEmailAndPassword(
      String name, String email, String password) async {
    // Check connectivity before attempting signup
    final hasInternet = await ConnectivityHelper.hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Create user with basic info (profile will be completed later)
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        profileComplete:
            false, // Will be set to true after additional info is collected
      );

      //Register the user in firestore
      await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());

      // Register user in backend API (required for chat functionality)
      await _registerUserInBackendAPI(name, email, password);

      // Generate and store auth token
      await TokenService.generateAndStoreToken();

      // Store user details in TokenService
      await TokenService.storeUserDetails(
        email: user.email,
        name: user.name,
        userId: user.uid,
        password: password, // Store password for backend API authentication
      );

      // Generate backend API token for chat functionality
      await TokenService.generateAndStoreBackendToken();

      AppLogger.i('Signup successful - Auth token generated and stored');

      //Return user
      return user;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _logError('Signup Failed', e);
      throw Exception('Signup Failed: ${e.toString()}');
    }
    return null;
  }

  Future<void> updateUserDisplayName(String displayName) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
    } catch (e) {
      _logError('Error updating display name', e);
      throw Exception('Update Display Name Failed: ${e.toString()}');
    }
  }

  void _handleAuthException(FirebaseAuthException e) {
    String message;
    if (kDebugMode) {
      print(e.message);
      print(e.code);
    }
    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'network-request-failed':
        message =
            'Network error. Please check your internet connection and try again.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'unknown-error':
        message = 'Either email or password is incorrect.';
        break;
      default:
        message = e.message ?? 'Unknown error';
    }
    throw Exception(message);
  }

  void _logError(String context, dynamic e) {
    if (kDebugMode) {
      print('$context: $e');
    }
  }

  // Helper method to register user in backend API with email/password
  Future<void> _registerUserInBackendAPI(
      String name, String email, String password) async {
    try {
      AppLogger.i('📝 Registering user in backend API: $email');

      const baseUrl = 'https://mental-health.rohanrichard.com';
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'age': '25', // Default values - can be updated later
          'gender_identity': 'Not Specified',
          'location': 'Not Specified',
        }),
      );

      AppLogger.d(
          'Backend registration response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Backend API registration successful');
      } else if (response.statusCode == 400) {
        // User might already exist in backend
        AppLogger.w(
            '⚠️ User already exists in backend - this is OK for returning users');
      } else {
        AppLogger.e('❌ Backend registration failed: ${response.statusCode}');
        AppLogger.e('Response: ${response.body}');
        // Don't throw - user can still use Firebase features
      }
    } catch (e) {
      AppLogger.e('💥 Error registering user in backend API: $e', data: e);
      // Don't throw - backend registration is optional for core Firebase features
    }
  }

  // Helper method to register user with backend API when password is not available (Google/Apple sign-in)
  Future<void> _registerUserWithBackend(String email, String name) async {
    try {
      AppLogger.i('Registering user with backend API: $email');

      const baseUrl = 'https://mental-health.rohanrichard.com';
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password':
              'oauth_user_${DateTime.now().millisecondsSinceEpoch}', // Auto-generated password for OAuth users
          'age':
              '25', // Default values for OAuth users - these can be updated later
          'gender_identity': 'Not Specified',
          'location': 'Not Specified',
        }),
      );

      AppLogger.d(
          'Backend registration response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        AppLogger.i('Backend registration successful for OAuth user');

        // Try to get an auth token for this user
        // Since we used an auto-generated password, we need to handle this differently
        // The backend should support OAuth token validation
      } else if (response.statusCode == 400) {
        // User might already exist, which is fine
        AppLogger.w(
            'User already exists in backend - this is expected for returning OAuth users');
      } else {
        AppLogger.e('Backend registration failed: ${response.statusCode}');
        AppLogger.e('Response: ${response.body}');
      }
    } catch (e) {
      AppLogger.e('Error registering user with backend API: $e', data: e);
      // Don't throw error - OAuth sign-in should still work even if backend registration fails
    }
  }

  @override
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logError('Error sending email', e);
      throw Exception('Failed to send email: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    // Check connectivity before attempting Google sign-in
    final hasInternet = await ConnectivityHelper.hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      // Extract user data
      User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google sign-in failed');
      }

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      bool isNewUser = !userDoc.exists;
      bool profileComplete = false;

      if (!userDoc.exists) {
        // New user - Register with incomplete profile
        AppUser user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? 'User',
          profileComplete: false, // Profile needs to be completed
        );

        await firebaseFirestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson());

        AppLogger.i('🆕 New Google user created - profile incomplete');
      } else {
        // Existing user - check if profile is complete
        final data = userDoc.data() as Map<String, dynamic>;
        profileComplete = data['profileComplete'] ?? false;
        AppLogger.i('👤 Existing user - profile complete: $profileComplete');
      }

      // Create AppUser instance with current profile state
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? 'User',
        age: isNewUser ? null : (userDoc.data() as Map<String, dynamic>)['age'],
        gender: isNewUser
            ? null
            : (userDoc.data() as Map<String, dynamic>)['gender'],
        location: isNewUser
            ? null
            : (userDoc.data() as Map<String, dynamic>)['location'],
        stressLevel: isNewUser
            ? null
            : (userDoc.data() as Map<String, dynamic>)['stressLevel'],
        profileComplete: profileComplete,
      );

      // Generate and store auth token
      await TokenService.generateAndStoreToken();

      // Store user details in TokenService
      await TokenService.storeUserDetails(
        email: appUser.email,
        name: appUser.name,
        userId: appUser.uid,
      );

      // For Google sign-in, try to register with backend if profile is complete
      if (profileComplete && !isNewUser) {
        await _registerUserWithBackend(appUser.email, appUser.name);
      }

      print('Google sign-in successful - Auth token generated and stored');

      // Return the user
      return appUser;
    } catch (e) {
      _logError('Error signing in with Google: ', e);
      throw Exception(
          'Error signing in with Google or canceled by user. You can try using email instead if the issue persists.');
    }
  }

  @override
  Future<AppUser?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.example.fantastic_app_riverpod',
          redirectUri: Uri.parse(
              'https://example.com/callbacks/sign_in_with_apple'), // Replace with our redirect URI (When Published of course)
        ),
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(oauthCredential);

      User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Apple sign-in failed');
      }

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      bool isNewUser = !userDoc.exists;
      bool profileComplete = false;

      if (!userDoc.exists) {
        // New user - Register with incomplete profile
        final userName = appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : firebaseUser.displayName ?? 'User';

        AppUser user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? 'No email',
          name: userName,
          profileComplete: false, // Profile needs to be completed
        );

        await firebaseFirestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson());

        AppLogger.i('🆕 New Apple user created - profile incomplete');
      } else {
        // Existing user - check if profile is complete
        final data = userDoc.data() as Map<String, dynamic>;
        profileComplete = data['profileComplete'] ?? false;
        AppLogger.i('👤 Existing user - profile complete: $profileComplete');
      }

      // Create AppUser instance with current profile state
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'No email',
        name: firebaseUser.displayName ?? 'User',
        age: isNewUser ? null : (userDoc.data() as Map<String, dynamic>)['age'],
        gender: isNewUser
            ? null
            : (userDoc.data() as Map<String, dynamic>)['gender'],
        location: isNewUser
            ? null
            : (userDoc.data() as Map<String, dynamic>)['location'],
        stressLevel: isNewUser
            ? null
            : (userDoc.data() as Map<String, dynamic>)['stressLevel'],
        profileComplete: profileComplete,
      );

      // Generate and store auth token
      await TokenService.generateAndStoreToken();

      // Store user details in TokenService
      await TokenService.storeUserDetails(
        email: appUser.email,
        name: appUser.name,
        userId: appUser.uid,
      );

      // For Apple sign-in, try to register with backend if profile is complete
      if (profileComplete && !isNewUser) {
        await _registerUserWithBackend(appUser.email, appUser.name);
      }

      print('Apple sign-in successful - Auth token generated and stored');

      // Return the user
      return appUser;
    } on PlatformException catch (e) {
      _logError('Error signing in with Apple (PlatformException): ', e);
      throw Exception(
          'Error signing in with Apple. Please ensure your configuration is correct.');
    } catch (e) {
      _logError('Error signing in with Apple: ', e);
      throw Exception(
          'Error signing in with Apple or canceled by user. You can try using email instead if the issue persists.');
    }
  }
}
