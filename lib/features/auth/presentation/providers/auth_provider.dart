import 'package:fantastic_app_riverpod/core/log/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../data/models/app_user.dart';
import '../../domain/repos/auth_repo.dart';
import '../../data/repo/firebase_auth_repo.dart';
import '../../../chat/data/services/token/token_service.dart';
import '../../../../core/services/onboarding_service.dart';

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
      AppLogger.i(
          'Firebase Auth State Changed in Provider: ${user?.uid ?? 'null'}');

      try {
        if (user != null) {
          // User is signed in, sync with token service
          await TokenService.syncWithFirebaseAuth();

          // Fetch full user data from Firestore to get profile completion status
          final fullUser = await authRepo.getCurrentUser();

          // Update state only if different from current user
          if (fullUser != null && state.user?.uid != user.uid) {
            state =
                state.copyWith(user: fullUser, isLoading: false, error: null);
            AppLogger.i('Auth state updated from Firebase listener');
          }
        } else {
          // User is signed out, clear state
          await TokenService.syncWithFirebaseAuth();
          if (state.user != null) {
            state = const AuthState();
            AppLogger.i('Auth state cleared from Firebase listener');
          }
        }
      } catch (e) {
        AppLogger.e('Error in Firebase auth state listener: $e');
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    });

    AppLogger.i('Firebase Auth state listener setup in AuthProvider');
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
        AppLogger.i('Valid Firebase token found, checking user data...');

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

          AppLogger.i('User authenticated from stored Firebase token');
          state = state.copyWith(user: user, isLoading: false);
          return;
        }
      }

      // If no valid token or stored data, check Firebase auth
      AppLogger.i('No valid token found, checking Firebase auth...');
      await checkAuth();
    } catch (e) {
      AppLogger.e('Error during auth initialization: $e');
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
          AppLogger.i('User authenticated and token stored');
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
      AppLogger.i('Starting Google Sign-In process');
      final user = await authRepo.signInWithGoogle();
      if (user != null) {
        AppLogger.i('Google Sign-In successful');
        state = state.copyWith(user: user, isLoading: false);
        // Token generation and storage is now handled in the repository
      } else {
        AppLogger.w('Google Sign-In returned null user');
        state = state.copyWith(
          isLoading: false,
          error: 'Google Sign-In failed: No user data returned',
        );
      }
    } catch (e) {
      AppLogger.e('Google Sign-In error: ${e.toString()}');
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

      // Clear onboarding status so next user has to complete onboarding
      try {
        await OnboardingService.clearOnboardingOnLogout();
        AppLogger.i('Onboarding status cleared');
      } catch (e) {
        AppLogger.w('Error clearing onboarding status: $e');
      }

      // This ensures no persistent state remains after logout
      AppLogger.i('User logged out successfully');
    } catch (e) {
      AppLogger.e('Error during logout: ${e.toString()}');
      // Still ensure state is reset even if there's an error
      state = const AuthState();
      // Also clear SharedPreferences even if Firebase logout fails
      try {
        await TokenService.clearAllData();
      } catch (clearError) {
        AppLogger.e('Error clearing local data: $clearError');
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
        AppLogger.w('Warning: No authenticated user found');
        return '';
      }
      final email = user.email;
      if (email.isEmpty) {
        AppLogger.w('Warning: Authenticated user has empty email');
      } else {
        AppLogger.i('Current user email from provider: $email');
      }
      return email;
    },
    loading: () {
      AppLogger.i('User data is loading...');
      return '';
    },
    error: (error, stackTrace) {
      AppLogger.e('Error getting user email: $error');
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
