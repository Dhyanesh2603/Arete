import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/peer_cohort.dart';
import 'auth_provider.dart';

class PeerCohortState {
  final PeerCohort cohort;
  final String currentUserId;

  const PeerCohortState({
    required this.cohort,
    required this.currentUserId,
  });

  PeerCohortState copyWith({
    PeerCohort? cohort,
    String? currentUserId,
  }) {
    return PeerCohortState(
      cohort: cohort ?? this.cohort,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class PeerCohortNotifier extends StateNotifier<PeerCohortState> {
  final Ref _ref;
  String? _currentUserId;

  PeerCohortNotifier(this._ref) : super(_defaultCohortState()) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          _loadSquad(newUserId, next.user?.name ?? 'Developer');
        } else {
          state = _defaultCohortState();
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      _loadSquad(initialUser.id, initialUser.name);
    }
  }

  static PeerCohortState _defaultCohortState() {
    return PeerCohortState(
      currentUserId: 'current_user',
      cohort: PeerCohort(
        id: 'squad-user',
        name: 'My Study Squad',
        targetGoal: 'FAANG & Top Product Software Engineer',
        members: [],
        sprintTargetProblems: 50,
        sprintDeadline: DateTime.now().add(const Duration(days: 14)),
      ),
    );
  }

  Future<void> _loadSquad(String userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_squad_members');

    final userMember = PeerMember(
      id: userId,
      name: userName.isNotEmpty ? userName : 'You',
      email: _ref.read(authProvider).user?.email ?? '',
      handle: '@${userName.toLowerCase().replaceAll(' ', '_')}',
      avatarColor: const Color(0xFF38BDF8),
      isOnline: true,
      isFocusingNow: false,
      problemsSolvedToday: 0,
      totalProblemsSolved: 0,
      streakDays: _ref.read(authProvider).user?.streakDays ?? 0,
      currentDsaTopic: 'General Practice',
    );

    List<PeerMember> members = [userMember];

    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final peers = list.map((item) {
          final m = item as Map<String, dynamic>;
          return PeerMember(
            id: m['id'] as String,
            name: m['name'] as String,
            email: m['email'] as String? ?? '',
            handle: m['handle'] as String? ?? '@peer',
            avatarColor: Color(m['avatarColor'] as int? ?? 0xFF818CF8),
            isOnline: m['isOnline'] as bool? ?? false,
            isInvited: m['isInvited'] as bool? ?? true,
            currentDsaTopic: m['currentDsaTopic'] as String? ?? 'Invited Peer',
          );
        }).toList();
        members.addAll(peers);
      } catch (_) {}
    }

    state = PeerCohortState(
      currentUserId: userId,
      cohort: state.cohort.copyWith(members: members),
    );
  }

  Future<void> invitePeerByEmail(String email, {String? name}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) return;

    final displayName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : trimmedEmail.split('@').first;

    final newMember = PeerMember(
      id: 'peer-${DateTime.now().millisecondsSinceEpoch}',
      name: displayName,
      email: trimmedEmail,
      handle: '@${displayName.toLowerCase().replaceAll(' ', '_')}',
      avatarColor: const Color(0xFF818CF8),
      isOnline: false,
      isInvited: true,
      currentDsaTopic: 'Invitation Sent',
    );

    final updatedMembers = [...state.cohort.members, newMember];
    state = state.copyWith(
      cohort: state.cohort.copyWith(members: updatedMembers),
    );

    await _persistSquad(updatedMembers);
  }

  Future<void> removeMember(String memberId) async {
    // Cannot remove oneself
    if (memberId == _currentUserId) return;

    final updatedMembers =
        state.cohort.members.where((m) => m.id != memberId).toList();
    state = state.copyWith(
      cohort: state.cohort.copyWith(members: updatedMembers),
    );

    await _persistSquad(updatedMembers);
  }

  Future<void> _persistSquad(List<PeerMember> members) async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    // Persist only invited peers
    final peers = members.where((m) => m.id != _currentUserId).map((m) => {
          'id': m.id,
          'name': m.name,
          'email': m.email,
          'handle': m.handle,
          'avatarColor': m.avatarColor.toARGB32(),
          'isOnline': m.isOnline,
          'isInvited': m.isInvited,
          'currentDsaTopic': m.currentDsaTopic,
        }).toList();

    await prefs.setString(
        'arete_user_${_currentUserId}_squad_members', jsonEncode(peers));
  }
}

final peerCohortProvider =
    StateNotifierProvider<PeerCohortNotifier, PeerCohortState>((ref) {
  return PeerCohortNotifier(ref);
});
