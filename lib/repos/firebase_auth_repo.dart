import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fantastic_app_riverpod/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';

import '../models/app_user.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Constructor to set persistence
  FirebaseAuthRepo() {
    _setPersistence();
    _setupAuthListener();
  }

  // Auth state listener
  void _setupAuthListener() {
    firebaseAuth.authStateChanges().listen((User? user) {
      if (kDebugMode) {
        if (user != null) {
          print(
              'Auth state changed: User is signed in with email: ${user.email}');
        } else {
          print('Auth state changed: User is signed out');
        }
      }
    });
  }

  // Set Firebase Auth persistence to ensure login persists across app restarts
  Future<void> _setPersistence() async {
    try {
      // For web platforms
      if (kIsWeb) {
        await firebaseAuth.setPersistence(Persistence.LOCAL);
      }
      // Mobile platforms have persistence enabled by default with CACHE persistence

      if (kDebugMode) {
        print('Firebase Auth persistence set successfully');

        // Check if a user is already signed in
        if (firebaseAuth.currentUser != null) {
          print('User already signed in: ${firebaseAuth.currentUser?.email}');
        }
      }
    } catch (e) {
      _logError('Error setting persistence', e);
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    //Get logged in user from firebase.
    final firebaseUser = firebaseAuth.currentUser;

    //No user logged in.
    if (firebaseUser == null) {
      return null;
    }

    try {
      //Fetch user document from firestore.
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection("users")
          .doc(firebaseUser.uid)
          .get();

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
    } catch (e) {
      _logError('Error getting current user data', e);
      // If we can't get Firestore data but have Firebase Auth user,
      // return basic user info to keep them logged in
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'No email',
        name: firebaseUser.displayName ?? 'User',
      );
    }
  }

  @override
  Future<AppUser?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting email login for: $email');
      }

      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify the user is logged in
      if (userCredential.user == null) {
        throw Exception('Login successful but no user returned');
      }

      if (kDebugMode) {
        print('Email login successful for: ${userCredential.user!.email}');
      }

      // Get complete user data from Firestore
      try {
        DocumentSnapshot userDoc = await firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          return AppUser(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? 'No email',
            name: userDoc['name'] ?? userCredential.user!.displayName ?? 'User',
          );
        }
      } catch (e) {
        _logError('Error getting user data from Firestore', e);
        // Continue with basic user info even if Firestore fails
      }

      // Fallback to basic user info if Firestore data not available
      return AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? 'No email',
        name: userCredential.user!.displayName ?? 'User',
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _logError('Login Failed', e);
      throw Exception('Login Failed: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut().timeout(const Duration(seconds: 10));
    } catch (e) {
      _logError('Error during logout', e);
      throw Exception('Logout Failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> signupWithEmailAndPassword(
      String name, String email, String password) async {
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

      //Return user
      return user;

      // return AppUser(
      //   uid: userCredential.user!.uid,
      //   email: userCredential.user!.email ?? 'No email',
      //   name: userCredential.user!.displayName ?? 'User',
      // );
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
    try {
      // Sign out first to clear previous Google account selection
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Now sign in with the account picker shown
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Handle case where user cancels the sign-in
      if (googleUser == null) {
        throw Exception('Google sign-in was canceled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
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

      // Return the user
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? 'User',
      );
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
          clientId:
              'com.example.fantastic_app_riverpod', //TODO: Replace with our app's client ID (When Published of course)
          redirectUri: Uri.parse(
              'https://example.com/callbacks/sign_in_with_apple'), //TODO: Replace with our redirect URI (When Published of course)
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

      // Return the user
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? 'No email',
        name: firebaseUser.displayName ?? 'User',
      );
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
