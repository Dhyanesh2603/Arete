import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/workspace_page.dart';
import 'auth_provider.dart';

class WorkspaceNotifier extends StateNotifier<List<WorkspacePage>> {
  final Ref _ref;
  String? _currentUserId;

  WorkspaceNotifier(this._ref) : super([]) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          loadUserPages(newUserId);
        } else {
          state = [];
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      loadUserPages(initialUser.id);
    }
  }

  Future<void> loadUserPages(String userId) async {
    final pages = await SupabaseService.fetchUserWorkspacePages(userId);
    state = pages;
  }

  Future<void> _persist() async {
    if (_currentUserId != null) {
      await SupabaseService.saveUserWorkspacePages(_currentUserId!, state);
    }
  }

  WorkspacePage? getPage(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<WorkspacePage> get rootPages {
    return state.where((p) => p.parentId == null || p.parentId!.isEmpty).toList();
  }

  List<WorkspacePage> getChildren(String parentId) {
    return state.where((p) => p.parentId == parentId).toList();
  }

  List<WorkspacePage> get pinnedPages {
    return state.where((p) => p.isPinned).toList();
  }

  List<WorkspacePage> get recentPages {
    final list = [...state];
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<WorkspacePage> createPage({
    String? parentId,
    String? title,
    String? icon,
    String? coverGradient,
    List<PageBlock>? initialBlocks,
  }) async {
    final now = DateTime.now();
    final newPage = WorkspacePage(
      id: UniqueKeyString.generate(),
      parentId: parentId,
      title: title ?? (parentId != null ? 'Subpage' : 'Untitled Document'),
      icon: icon ?? 'article',
      coverGradient: coverGradient,
      blocks: initialBlocks ??
          [
            PageBlock(
              id: UniqueKeyString.generate(),
              type: PageBlockType.paragraph,
              content: '',
            ),
          ],
      createdAt: now,
      updatedAt: now,
    );

    state = [newPage, ...state];
    await _persist();
    return newPage;
  }

  Future<void> updatePageTitle(String pageId, String title) async {
    state = state.map((p) {
      if (p.id == pageId) {
        return p.copyWith(
          title: title,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> updatePageIcon(String pageId, String icon) async {
    state = state.map((p) {
      if (p.id == pageId) {
        return p.copyWith(
          icon: icon,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> updatePageCover(String pageId, String? coverGradient) async {
    state = state.map((p) {
      if (p.id == pageId) {
        return p.copyWith(
          coverGradient: coverGradient,
          clearCover: coverGradient == null,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> togglePin(String pageId) async {
    state = state.map((p) {
      if (p.id == pageId) {
        return p.copyWith(
          isPinned: !p.isPinned,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> toggleFavorite(String pageId) async {
    state = state.map((p) {
      if (p.id == pageId) {
        return p.copyWith(
          isFavorite: !p.isFavorite,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> deletePage(String pageId) async {
    // Collect all descendant ids recursively
    final idsToDelete = <String>{pageId};
    void collectDescendants(String pid) {
      for (final p in state) {
        if (p.parentId == pid) {
          idsToDelete.add(p.id);
          collectDescendants(p.id);
        }
      }
    }
    collectDescendants(pageId);

    state = state.where((p) => !idsToDelete.contains(p.id)).toList();
    await _persist();
  }

  Future<void> addBlock(
    String pageId,
    PageBlockType type, {
    String content = '',
    int? atIndex,
    String? language,
    String? calloutType,
  }) async {
    final newBlock = PageBlock(
      id: UniqueKeyString.generate(),
      type: type,
      content: content,
      language: language,
      calloutType: calloutType,
    );

    state = state.map((p) {
      if (p.id == pageId) {
        final currentBlocks = List<PageBlock>.from(p.blocks);
        if (atIndex != null && atIndex >= 0 && atIndex <= currentBlocks.length) {
          currentBlocks.insert(atIndex, newBlock);
        } else {
          currentBlocks.add(newBlock);
        }
        return p.copyWith(
          blocks: currentBlocks,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> updateBlockContent(
    String pageId,
    String blockId,
    String content,
  ) async {
    state = state.map((p) {
      if (p.id == pageId) {
        final currentBlocks = p.blocks.map((b) {
          if (b.id == blockId) {
            return b.copyWith(content: content);
          }
          return b;
        }).toList();
        return p.copyWith(
          blocks: currentBlocks,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> toggleBlockCheck(String pageId, String blockId) async {
    state = state.map((p) {
      if (p.id == pageId) {
        final currentBlocks = p.blocks.map((b) {
          if (b.id == blockId) {
            return b.copyWith(isChecked: !b.isChecked);
          }
          return b;
        }).toList();
        return p.copyWith(
          blocks: currentBlocks,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> toggleBlockExpanded(String pageId, String blockId) async {
    state = state.map((p) {
      if (p.id == pageId) {
        final currentBlocks = p.blocks.map((b) {
          if (b.id == blockId) {
            return b.copyWith(isExpanded: !b.isExpanded);
          }
          return b;
        }).toList();
        return p.copyWith(
          blocks: currentBlocks,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> deleteBlock(String pageId, String blockId) async {
    state = state.map((p) {
      if (p.id == pageId) {
        final currentBlocks = p.blocks.where((b) => b.id != blockId).toList();
        // Keep at least 1 empty block so the page is always editable
        if (currentBlocks.isEmpty) {
          currentBlocks.add(PageBlock(
            id: UniqueKeyString.generate(),
            type: PageBlockType.paragraph,
            content: '',
          ));
        }
        return p.copyWith(
          blocks: currentBlocks,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }

  Future<void> reorderBlocks(
    String pageId,
    int oldIndex,
    int newIndex,
  ) async {
    state = state.map((p) {
      if (p.id == pageId) {
        final currentBlocks = List<PageBlock>.from(p.blocks);
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = currentBlocks.removeAt(oldIndex);
        currentBlocks.insert(newIndex, item);
        return p.copyWith(
          blocks: currentBlocks,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();
    await _persist();
  }
}

final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, List<WorkspacePage>>((ref) {
  return WorkspaceNotifier(ref);
});
