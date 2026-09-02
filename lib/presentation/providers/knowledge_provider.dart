import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/knowledge_note.dart';
import 'auth_provider.dart';

class KnowledgeNotifier extends StateNotifier<List<KnowledgeNote>> {
  final Ref _ref;
  String? _currentUserId;

  KnowledgeNotifier(this._ref) : super([]) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          loadUserNotes(newUserId);
        } else {
          state = [];
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      loadUserNotes(initialUser.id);
    }
  }

  Future<void> loadUserNotes(String userId) async {
    final userNotes = await SupabaseService.fetchUserNotes(userId);
    state = userNotes;
  }

  Future<void> addNote(KnowledgeNote note) async {
    final updated = [note, ...state];
    state = updated;
    if (_currentUserId != null) {
      await SupabaseService.saveUserNotes(_currentUserId!, updated);
    }
  }

  Future<void> updateNote(String id, String newMarkdown, String newTitle) async {
    final updated = state.map((n) {
      if (n.id == id) {
        return n.copyWith(
          title: newTitle,
          contentMarkdown: newMarkdown,
          updatedAt: DateTime.now(),
        );
      }
      return n;
    }).toList();

    state = updated;
    if (_currentUserId != null) {
      await SupabaseService.saveUserNotes(_currentUserId!, updated);
    }
  }

  Future<void> deleteNote(String id) async {
    final updated = state.where((n) => n.id != id).toList();
    state = updated;
    if (_currentUserId != null) {
      await SupabaseService.saveUserNotes(_currentUserId!, updated);
    }
  }
}

final knowledgeProvider =
    StateNotifierProvider<KnowledgeNotifier, List<KnowledgeNote>>((ref) {
  return KnowledgeNotifier(ref);
});
