import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../repos/auth_repo.dart';
import '../repos/firebase_auth_repo.dart';

// Define an Auth State
class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({AppUser? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// AuthNotifier extends StateNotifier to manage authentication
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepo authRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier({required this.authRepo}) : super(const AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await authRepo.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await authRepo.loginWithEmailAndPassword(email, password);
      state = state.copyWith(user: user, isLoading: false);
      // Removed the call to _addUserToTesters(user) here
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user =
          await authRepo.signupWithEmailAndPassword(name, email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
    state =
        state.copyWith(isLoading: true, error: null); // Clear previous errors
    try {
      print('Starting Google Sign-In process');
      final user = await authRepo.signInWithGoogle();
      if (user != null) {
        print('Google Sign-In successful');
        state = state.copyWith(user: user, isLoading: false);
      } else {
        print('Google Sign-In returned null user');
        state = state.copyWith(
          isLoading: false,
          error: 'Google Sign-In failed: No user data returned',
        );
      }
    } catch (e) {
      print('Google Sign-In error: ${e.toString()}');
      state = state.copyWith(
        error: 'Google Sign-In failed: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await authRepo.signInWithApple();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> sendForgotPasswordLink(String email) async {
    try {
      await authRepo.sendPasswordResetLink(email);
    } catch (e) {
      state = state.copyWith(
          error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await authRepo.logout();
    state = const AuthState();
  }
}

// Define the provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(authRepo: ref.read(authRepoProvider));
});

// AuthRepo Provider
final authRepoProvider = Provider<AuthRepo>((ref) {
  return FirebaseAuthRepo();
});

// Provider for the authentication repository
final authRepositoryProvider = Provider<AuthRepo>((ref) {
  return FirebaseAuthRepo();
});

// Provider for the current user
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});

// Provider for the current user's email - improved to handle authentication state
final userEmailProvider = Provider<String>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        print('Warning: No authenticated user found');
        return '';
      }
      final email = user.email ?? '';
      if (email.isEmpty) {
        print('Warning: Authenticated user has empty email');
      } else {
        print('Current user email from provider: $email');
      }
      return email;
    },
    loading: () {
      print('User data is loading...');
      return '';
    },
    error: (error, stackTrace) {
      print('Error getting user email: $error');
      return '';
    },
  );
});

// Email Storage class to store and provide the current email
class EmailStorage {
  final String _email;

  EmailStorage(this._email);

  // Getter to retrieve the stored email
  String get email => _email;

  // Check if email is valid and available
  bool get hasValidEmail => _email.isNotEmpty;
}

// Provider for EmailStorage that uses userEmailProvider directly
final emailStorageProvider = Provider<EmailStorage>((ref) {
  final email = ref.watch(userEmailProvider);
  return EmailStorage(email);
});

// Convenience function to get email as a string
final currentEmailProvider = Provider<String>((ref) {
  return ref.watch(emailStorageProvider).email;
});

// Utility function to check if user has valid email
final hasValidEmailProvider = Provider<bool>((ref) {
  return ref.watch(emailStorageProvider).hasValidEmail;
});

// Utility function to get current user email from anywhere
String getCurrentUserEmail(WidgetRef ref) {
  return ref.read(currentEmailProvider);
}
