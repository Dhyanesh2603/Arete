import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import '../../domain/models/dsa_problem.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/knowledge_note.dart';
import '../../domain/models/task.dart';
import '../../domain/models/user_profile.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isSupabaseConfigured = false;

  // Public project configuration
  static String supabaseUrl = const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hojmtegkcucjmdbhiflp.supabase.co',
  );
  static String supabaseAnonKey = const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhvam10ZWdrY3Vjam1kYmhpZmxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgzNDg0OTAsImV4cCI6MjEwMzkyNDQ5MH0.phNJR_B8PdPUjH0pvoBWQhgc1i_y52i_KdYtsQL6zbs',
  );

  static Future<void> initialize({String? url, String? anonKey}) async {
    final targetUrl = url ?? supabaseUrl;
    final targetKey = anonKey ?? supabaseAnonKey;

    if (targetUrl.isNotEmpty && targetKey.isNotEmpty && !targetUrl.contains('xyzcompany')) {
      try {
        _client = SupabaseClient(targetUrl, targetKey);
        _isSupabaseConfigured = true;
      } catch (e) {
        _isSupabaseConfigured = false;
      }
    } else {
      _isSupabaseConfigured = false;
    }
  }

  static SupabaseClient? get client => _client;
  static bool get isConfigured => _isSupabaseConfigured;

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  static Future<UserProfile?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final userId = 'usr-${email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

    if (_isSupabaseConfigured && _client != null) {
      try {
        final res = await _client!.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'name': name.trim()},
        );
        if (res.user != null) {
          final profile = UserProfile(
            id: res.user!.id,
            name: name.trim(),
            email: email.trim(),
            targetRole: 'Software Engineer & DSA Aspirant',
            avatarColor: const Color(0xFF38BDF8),
            streakDays: 0,
            totalProblemsSolved: 0,
            totalFocusHours: 0.0,
            createdAt: DateTime.now(),
          );
          await saveUserProfile(profile);
          await _setCurrentSessionUserId(res.user!.id);
          return profile;
        }
      } on AuthException catch (e) {
        throw e.message;
      } catch (_) {
        // Network fallback
      }
    }

    final profile = UserProfile(
      id: userId,
      name: name.trim(),
      email: email.trim(),
      targetRole: 'Software Engineer & DSA Aspirant',
      avatarColor: const Color(0xFF818CF8),
      streakDays: 0,
      totalProblemsSolved: 0,
      totalFocusHours: 0.0,
      createdAt: DateTime.now(),
    );

    // Save profile into isolated partition
    await saveUserProfile(profile);
    await _setCurrentSessionUserId(userId);
    return profile;
  }

  static Future<UserProfile?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final userId = 'usr-${email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

    if (_isSupabaseConfigured && _client != null) {
      try {
        final res = await _client!.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (res.user != null) {
          var profile = await fetchUserProfile(res.user!.id);
          if (profile == null) {
            final formattedName = email.split('@').first;
            profile = UserProfile(
              id: res.user!.id,
              name: formattedName.isNotEmpty
                  ? formattedName[0].toUpperCase() + formattedName.substring(1)
                  : 'User',
              email: email.trim(),
              createdAt: DateTime.now(),
            );
            await saveUserProfile(profile);
          }
          await _setCurrentSessionUserId(profile.id);
          return profile;
        }
      } on AuthException catch (e) {
        throw e.message;
      } catch (_) {
        // Network fallback
      }
    }

    var profile = await fetchUserProfile(userId);
    if (profile == null) {
      final formattedName = email.split('@').first;
      profile = UserProfile(
        id: userId,
        name: formattedName.isNotEmpty
            ? formattedName[0].toUpperCase() + formattedName.substring(1)
            : 'User',
        email: email.trim(),
        targetRole: 'Software Engineer & DSA Aspirant',
        avatarColor: const Color(0xFF38BDF8),
        streakDays: 0,
        totalProblemsSolved: 0,
        totalFocusHours: 0.0,
        createdAt: DateTime.now(),
      );
      await saveUserProfile(profile);
    }
    await _setCurrentSessionUserId(userId);
    return profile;
  }

  static Future<void> signOut() async {
    if (_isSupabaseConfigured && _client != null) {
      try {
        await _client!.auth.signOut();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('arete_active_session_user_id');
  }

  static Future<String?> getActiveSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('arete_active_session_user_id');
  }

  static Future<void> _setCurrentSessionUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arete_active_session_user_id', userId);
  }

  // ==========================================
  // PER-USER PROFILES
  // ==========================================

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'id': profile.id,
      'name': profile.name,
      'email': profile.email,
      'targetRole': profile.targetRole,
      'avatarColor': profile.avatarColor.toARGB32(),
      'streakDays': profile.streakDays,
      'totalProblemsSolved': profile.totalProblemsSolved,
      'totalFocusHours': profile.totalFocusHours,
      'createdAt': profile.createdAt.toIso8601String(),
    };
    await prefs.setString('arete_profile_${profile.id}', jsonEncode(data));
  }

  static Future<UserProfile?> fetchUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_profile_$userId');
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        targetRole: m['targetRole'] as String? ?? 'Software Engineer',
        avatarColor: Color(m['avatarColor'] as int? ?? 0xFF38BDF8),
        streakDays: m['streakDays'] as int? ?? 0,
        totalProblemsSolved: m['totalProblemsSolved'] as int? ?? 0,
        totalFocusHours: (m['totalFocusHours'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // PER-USER TASKS (Starts with 0 for new user)
  // ==========================================

  static Future<List<Task>> fetchUserTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_tasks');
    if (raw == null) {
      // Clean account: returns completely empty list
      return [];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        final priorityStr = m['priority'] as String? ?? 'medium';
        final priority = TaskPriority.values.firstWhere(
          (p) => p.name == priorityStr,
          orElse: () => TaskPriority.medium,
        );

        return Task(
          id: m['id'] as String,
          title: m['title'] as String,
          priority: priority,
          estimatedMinutes: m['estimatedMinutes'] as int? ?? 45,
          estimatedPomodoros: m['estimatedPomodoros'] as int? ?? 1,
          isCompleted: m['isCompleted'] as bool? ?? false,
          projectTag: m['projectTag'] as String?,
          milestoneTitle: m['milestoneTitle'] as String?,
          dueDate: m['dueDate'] != null ? DateTime.tryParse(m['dueDate'] as String) : null,
          completedAt: m['completedAt'] != null ? DateTime.tryParse(m['completedAt'] as String) : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUserTasks(String userId, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => {
      'id': t.id,
      'title': t.title,
      'priority': t.priority.name,
      'estimatedMinutes': t.estimatedMinutes,
      'estimatedPomodoros': t.estimatedPomodoros,
      'isCompleted': t.isCompleted,
      'projectTag': t.projectTag,
      'milestoneTitle': t.milestoneTitle,
      'dueDate': t.dueDate?.toIso8601String(),
      'completedAt': t.completedAt?.toIso8601String(),
    }).toList();

    await prefs.setString('arete_user_${userId}_tasks', jsonEncode(jsonList));
  }

  // ==========================================
  // PER-USER DSA PROGRESS (Starts with 0 for new user)
  // ==========================================

  static Future<Map<String, dynamic>> fetchUserDsaProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_dsa');
    if (raw == null) {
      return {};
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveUserDsaProblemStatus(
    String userId,
    String problemId,
    DsaStatus status, {
    int reviewCount = 0,
    DateTime? nextRevisionDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await fetchUserDsaProgress(userId);
    existing[problemId] = {
      'status': status.name,
      'reviewCount': reviewCount,
      'nextRevisionDate': nextRevisionDate?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString('arete_user_${userId}_dsa', jsonEncode(existing));
  }

  // ==========================================
  // PER-USER NOTES & HABITS
  // ==========================================

  static Future<List<KnowledgeNote>> fetchUserNotes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_notes');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        return KnowledgeNote(
          id: m['id'] as String,
          title: m['title'] as String,
          contentMarkdown: m['contentMarkdown'] as String,
          category: m['category'] as String? ?? 'General',
          updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUserNotes(String userId, List<KnowledgeNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => {
      'id': n.id,
      'title': n.title,
      'contentMarkdown': n.contentMarkdown,
      'category': n.category,
      'updatedAt': n.updatedAt.toIso8601String(),
    }).toList();
    await prefs.setString('arete_user_${userId}_notes', jsonEncode(jsonList));
  }

  static Future<List<Habit>> fetchUserHabits(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_habits');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        final freqStr = m['frequency'] as String? ?? 'dailyMorning';
        final freq = HabitFrequency.values.firstWhere(
          (f) => f.name == freqStr,
          orElse: () => HabitFrequency.dailyMorning,
        );

        return Habit(
          id: m['id'] as String,
          title: m['title'] as String,
          frequency: freq,
          consistencyScore: (m['consistencyScore'] as num?)?.toDouble() ?? 100.0,
          isCompletedToday: m['isCompletedToday'] as bool? ?? false,
          last30DaysHistory: (m['last30DaysHistory'] as List<dynamic>?)?.map((e) => e as bool).toList() ?? [],
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveUserHabits(String userId, List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = habits.map((h) => {
      'id': h.id,
      'title': h.title,
      'frequency': h.frequency.name,
      'consistencyScore': h.consistencyScore,
      'isCompletedToday': h.isCompletedToday,
      'last30DaysHistory': h.last30DaysHistory,
    }).toList();
    await prefs.setString('arete_user_${userId}_habits', jsonEncode(jsonList));
  }
}
