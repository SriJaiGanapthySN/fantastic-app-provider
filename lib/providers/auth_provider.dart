import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/app_user.dart';
import '../repos/auth_repo.dart';
import '../repos/firebase_auth_repo.dart';
import '../services/token_service.dart';

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
  StreamSubscription<User?>? _authStateSubscription;

  AuthNotifier({required this.authRepo}) : super(const AuthState()) {
    _initializeAuth();
    _setupFirebaseAuthListener();
  }

  // Setup Firebase Auth state listener for real-time updates
  void _setupFirebaseAuthListener() {
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      print(
          '🔥 Firebase Auth State Changed in Provider: ${user?.uid ?? 'null'}');

      try {
        if (user != null) {
          // User is signed in, sync with token service
          await TokenService.syncWithFirebaseAuth();

          // Create AppUser from Firebase user
          final appUser = AppUser(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
          );

          // Update state only if different from current user
          if (state.user?.uid != user.uid) {
            state =
                state.copyWith(user: appUser, isLoading: false, error: null);
            print('🔄 Auth state updated from Firebase listener');
          }
        } else {
          // User is signed out, clear state
          await TokenService.syncWithFirebaseAuth();
          if (state.user != null) {
            state = const AuthState();
            print('🚪 Auth state cleared from Firebase listener');
          }
        }
      } catch (e) {
        print('💥 Error in Firebase auth state listener: $e');
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    });

    print('🎧 Firebase Auth state listener setup in AuthProvider');
  }

  // Initialize authentication by checking stored tokens first
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      // Initialize Firebase auth listener in TokenService
      TokenService.initializeFirebaseAuthListener();

      // First check if we have a valid stored token
      final hasValidToken = await TokenService.validateToken();

      if (hasValidToken) {
        print('✅ Valid Firebase token found, checking user data...');

        // Try to get user from stored data
        final storedEmail = await TokenService.getUserEmail();
        final storedName = await TokenService.getUserName();
        final storedUserId = await TokenService.getUserId();

        if (storedEmail != null && storedUserId != null) {
          // Create user from stored data
          final user = AppUser(
            uid: storedUserId,
            email: storedEmail,
            name: storedName ?? 'User',
          );

          print('✅ User authenticated from stored Firebase token');
          state = state.copyWith(user: user, isLoading: false);
          return;
        }
      }

      // If no valid token or stored data, check Firebase auth
      print('🔍 No valid token found, checking Firebase auth...');
      await checkAuth();
    } catch (e) {
      print('💥 Error during auth initialization: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await authRepo.getCurrentUser();

      if (user != null) {
        // User is authenticated in Firebase, generate and store token
        final token = await TokenService.generateAndStoreToken();
        if (token != null) {
          await TokenService.storeUserDetails(
            email: user.email,
            name: user.name,
            userId: user.uid,
          );
          print('User authenticated and token stored');
        }
      }

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
      // Token generation and storage is now handled in the repository
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
        // Token generation and storage is now handled in the repository
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
    state = state.copyWith(isLoading: true);
    try {
      // First clear the state so UI updates immediately
      state = const AuthState();

      // Then complete the logout process (includes token clearing)
      await authRepo.logout();

      // This ensures no persistent state remains after logout
      print('🚪 User successfully logged out');
    } catch (e) {
      print('💥 Error during logout: ${e.toString()}');
      // Still ensure state is reset even if there's an error
      state = const AuthState();
      // Also clear SharedPreferences even if Firebase logout fails
      try {
        await TokenService.clearAllData();
      } catch (clearError) {
        print('💥 Error clearing local data: $clearError');
      }
    }
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    TokenService.disposeFirebaseAuthListener();
    super.dispose();
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
      final email = user.email;
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
