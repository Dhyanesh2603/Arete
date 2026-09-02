import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/learning_resource.dart';
import 'auth_provider.dart';

class ResourcesNotifier extends StateNotifier<List<LearningResource>> {
  final Ref _ref;
  String? _currentUserId;

  ResourcesNotifier(this._ref) : super([]) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          _loadResources(newUserId);
        } else {
          state = [];
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      _loadResources(initialUser.id);
    }
  }

  Future<void> _loadResources(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_resources');
    if (raw == null) {
      state = [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = list.map((item) {
        final m = item as Map<String, dynamic>;
        final typeStr = m['type'] as String? ?? 'course';
        final type = ResourceType.values.firstWhere(
          (t) => t.name == typeStr,
          orElse: () => ResourceType.course,
        );

        return LearningResource(
          id: m['id'] as String,
          title: m['title'] as String,
          authorOrPlatform: m['authorOrPlatform'] as String? ?? '',
          type: type,
          totalUnits: m['totalUnits'] as int? ?? 1,
          completedUnits: m['completedUnits'] as int? ?? 0,
          keyTakeaways: m['keyTakeaways'] as String? ?? '',
          externalUrl: m['externalUrl'] as String?,
        );
      }).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> addResource(LearningResource resource) async {
    final updated = [...state, resource];
    state = updated;
    await _persist(updated);
  }

  Future<void> deleteResource(String id) async {
    final updated = state.where((r) => r.id != id).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> updateUnits(String id, int completed) async {
    final updated = state.map((r) {
      if (r.id == id) {
        return r.copyWith(completedUnits: completed.clamp(0, r.totalUnits));
      }
      return r;
    }).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> _persist(List<LearningResource> resources) async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = resources.map((r) => {
          'id': r.id,
          'title': r.title,
          'authorOrPlatform': r.authorOrPlatform,
          'type': r.type.name,
          'totalUnits': r.totalUnits,
          'completedUnits': r.completedUnits,
          'keyTakeaways': r.keyTakeaways,
          'externalUrl': r.externalUrl,
        }).toList();
    await prefs.setString(
        'arete_user_${_currentUserId}_resources', jsonEncode(data));
  }
}

final resourcesProvider =
    StateNotifierProvider<ResourcesNotifier, List<LearningResource>>((ref) {
  return ResourcesNotifier(ref);
});
