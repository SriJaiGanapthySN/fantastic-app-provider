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
      error: error,
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
