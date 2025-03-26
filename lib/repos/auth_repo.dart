// The AuthRepo outlines the possible auth operations that can be done for this application.

import '../models/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailAndPassword(
    String email,
    String password,
  );
  Future<AppUser?> signupWithEmailAndPassword(
    String name,
    String email,
    String password,
  );
  Future<AppUser?> signInWithGoogle();
  Future<void> sendPasswordResetLink(
    String email,
  );
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
