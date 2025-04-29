import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    state = state.copyWith(isLoading: true);
    try {
      final user = await authRepo.signInWithGoogle();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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

// Provider for the current user's email
final userEmailProvider = Provider<String>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      final email = user?.email ?? '';
      print('Current user email from provider: $email');
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

// Fallback email for development
final fallbackEmailProvider = Provider<String>((ref) => "03@gmail.com");

// Provider that never returns an empty email
final safeUserEmailProvider = Provider<String>((ref) {
  final userEmail = ref.watch(userEmailProvider);
  final fallbackEmail = ref.watch(fallbackEmailProvider);

  final email = userEmail.isNotEmpty ? userEmail : fallbackEmail;
  print('Safe email provider returning: $email');
  return email;
});
