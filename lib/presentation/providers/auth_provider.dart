import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  AuthNotifier() : super(_defaultGuestState());

  static AuthState _defaultGuestState() {
    return AuthState(
      user: UserProfile(
        id: 'usr-1',
        name: 'Dhyanesh',
        email: 'dhyanesh@arete.app',
        targetRole: 'Senior AI & Systems Architect',
        avatarColor: const Color(0xFF38BDF8),
        streakDays: 42,
        totalProblemsSolved: 48,
        totalFocusHours: 24.5,
        createdAt: DateTime.now().subtract(const Duration(days: 42)),
      ),
      isAuthenticated: true,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (email.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter a valid email address.',
      );
      return false;
    }

    final name = email.split('@').first;
    final formattedName = name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1)
        : 'User';

    state = AuthState(
      user: UserProfile(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        name: formattedName,
        email: email.trim(),
        targetRole: 'Software Engineer & DSA Aspirant',
        avatarColor: const Color(0xFF34D399),
        streakDays: 1,
        totalProblemsSolved: 0,
        totalFocusHours: 0.0,
        createdAt: DateTime.now(),
      ),
      isAuthenticated: true,
      isLoading: false,
    );
    return true;
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (name.trim().isEmpty || email.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter both your name and email.',
      );
      return false;
    }

    state = AuthState(
      user: UserProfile(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: email.trim(),
        targetRole: 'Software Engineer & DSA Aspirant',
        avatarColor: const Color(0xFF818CF8),
        streakDays: 1,
        totalProblemsSolved: 0,
        totalFocusHours: 0.0,
        createdAt: DateTime.now(),
      ),
      isAuthenticated: true,
      isLoading: false,
    );
    return true;
  }

  void guestLogin() {
    state = AuthState(
      user: UserProfile(
        id: 'usr-guest',
        name: 'Dhyanesh (Guest)',
        email: 'guest@arete.app',
        targetRole: 'DSA & Systems Aspirant',
        avatarColor: const Color(0xFF38BDF8),
        streakDays: 42,
        totalProblemsSolved: 48,
        totalFocusHours: 24.5,
        createdAt: DateTime.now().subtract(const Duration(days: 42)),
      ),
      isAuthenticated: true,
      isLoading: false,
    );
  }

  void logout() {
    state = const AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  void updateProfile({String? name, String? targetRole}) {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          name: name ?? state.user!.name,
          targetRole: targetRole ?? state.user!.targetRole,
        ),
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
