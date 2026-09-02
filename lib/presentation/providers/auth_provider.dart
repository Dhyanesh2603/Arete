import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/user_profile.dart';

class AuthState {
  final UserProfile? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserProfile? user,
    bool clearUser = false,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isAuthenticated: false));

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter both your email and password.',
      );
      return false;
    }

    try {
      final profile = await SupabaseService.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (profile != null) {
        state = AuthState(
          user: profile,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication failed. Please check your credentials.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in: $e',
      );
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please fill in all fields (name, email, password).',
      );
      return false;
    }

    try {
      final profile = await SupabaseService.signUp(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      if (profile != null) {
        // Starts with clean 0 state
        state = AuthState(
          user: profile,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sign up failed. Please try again.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create account: $e',
      );
      return false;
    }
  }

  void guestLogin() {
    state = AuthState(
      user: UserProfile(
        id: 'usr-guest',
        name: 'Guest Explorer',
        email: 'guest@arete.app',
        targetRole: 'Software Engineer & DSA Aspirant',
        avatarColor: const Color(0xFF38BDF8),
        streakDays: 0,
        totalProblemsSolved: 0,
        totalFocusHours: 0.0,
        createdAt: DateTime.now(),
      ),
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    state = const AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  Future<void> updateProfile({String? name, String? targetRole}) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        name: name ?? state.user!.name,
        targetRole: targetRole ?? state.user!.targetRole,
      );
      await SupabaseService.saveUserProfile(updated);
      state = state.copyWith(user: updated);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
