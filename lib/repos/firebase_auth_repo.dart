import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fantastic_app_riverpod/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/app_user.dart';
import '../utils/connectivity_helper.dart';
import '../services/token_service.dart';

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

    //User exists
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc['name'],
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

      // Store user details in TokenService
      await TokenService.storeUserDetails(
        email: appUser.email,
        name: appUser.name,
        userId: appUser.uid,
        password: password, // Store password for backend API authentication
      );

      // Generate backend API token for chat functionality
      await TokenService.generateAndStoreBackendToken();

      print('Login successful - Auth token generated and stored');
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

      //Create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      //Register the user in firestore
      await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());

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

      print('Signup successful - Auth token generated and stored');

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

  // Helper method to register user with backend API when password is not available (Google/Apple sign-in)
  Future<void> _registerUserWithBackend(String email, String name) async {
    try {
      print('Registering user with backend API: $email');

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

      print('Backend registration response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Backend registration successful for OAuth user');

        // Try to get an auth token for this user
        // Since we used an auto-generated password, we need to handle this differently
        // The backend should support OAuth token validation
      } else if (response.statusCode == 400) {
        // User might already exist, which is fine
        print(
            'User already exists in backend - this is expected for returning OAuth users');
      } else {
        print('Backend registration failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error registering user with backend API: $e');
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

      if (!userDoc.exists) {
        // Register the new user in Firestore
        AppUser user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? 'User',
        );

        await firebaseFirestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson());
      }

      // Create AppUser instance
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? 'User',
      );

      // Generate and store auth token
      await TokenService.generateAndStoreToken();

      // Store user details in TokenService
      await TokenService.storeUserDetails(
        email: appUser.email,
        name: appUser.name,
        userId: appUser.uid,
      );

      // For Google sign-in, we need to register the user with the backend API first
      // since we don't have their password for backend authentication
      await _registerUserWithBackend(appUser.email, appUser.name);

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

      if (!userDoc.exists) {
        // Register the new user in Firestore
        AppUser user = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? 'No email',
          name: appleCredential.givenName != null &&
                  appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : firebaseUser.displayName ?? 'User',
        );

        await firebaseFirestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson());
      }

      // Create AppUser instance
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'No email',
        name: firebaseUser.displayName ?? 'User',
      );

      // Generate and store auth token
      await TokenService.generateAndStoreToken();

      // Store user details in TokenService
      await TokenService.storeUserDetails(
        email: appUser.email,
        name: appUser.name,
        userId: appUser.uid,
      );

      // For Apple sign-in, we need to register the user with the backend API first
      // since we don't have their password for backend authentication
      await _registerUserWithBackend(appUser.email, appUser.name);

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
