import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/knowledge_note.dart';
import '../../providers/knowledge_provider.dart';

class KnowledgeView extends ConsumerStatefulWidget {
  const KnowledgeView({super.key});

  @override
  ConsumerState<KnowledgeView> createState() => _KnowledgeViewState();
}

class _KnowledgeViewState extends ConsumerState<KnowledgeView> {
  int _selectedNoteIndex = 0;
  bool _isPreviewMode = false;
  String _searchQuery = '';
  String? _selectedCategoryFilter;

  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  String? _currentlyEditingNoteId;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _contentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _syncControllers(KnowledgeNote note) {
    if (_currentlyEditingNoteId != note.id) {
      _currentlyEditingNoteId = note.id;
      _titleCtrl.text = note.title;
      _contentCtrl.text = note.contentMarkdown;
    }
  }

  void _saveCurrentNote(KnowledgeNote note) {
    ref.read(knowledgeProvider.notifier).updateNote(
          note.id,
          _contentCtrl.text,
          _titleCtrl.text.trim().isEmpty ? 'Untitled Note' : _titleCtrl.text.trim(),
        );
  }

  void _createNoteWithTemplate(String title, String category, String markdown) {
    final newNote = KnowledgeNote(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      contentMarkdown: markdown,
      updatedAt: DateTime.now(),
    );
    ref.read(knowledgeProvider.notifier).addNote(newNote);
    setState(() {
      _selectedNoteIndex = 0;
      _currentlyEditingNoteId = null;
      _isPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = ref.watch(knowledgeProvider);
    final notesNotifier = ref.read(knowledgeProvider.notifier);

    // Filter notes
    final filteredNotes = allNotes.where((n) {
      if (_selectedCategoryFilter != null && n.category != _selectedCategoryFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = n.title.toLowerCase().contains(q);
        final matchesContent = n.contentMarkdown.toLowerCase().contains(q);
        final matchesCategory = n.category.toLowerCase().contains(q);
        if (!matchesTitle && !matchesContent && !matchesCategory) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KNOWLEDGE BASE & ARCHITECTURE NOTES', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Distraction-free markdown studio linking system specifications, algorithms, and architectures.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    _createNoteWithTemplate(
                      'New Architecture Note',
                      'Engineering',
                      '# New Architecture Note\n\n## Overview\nDocument core architectural principles, invariants, and specs here.\n\n## System Diagram\n- Component A -> Component B\n\n## Performance Invariants\n- Latency: < 50ms\n- Memory footprint: O(N)\n',
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF09090B)),
                  label: Text(
                    'NEW NOTE',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF09090B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main Body: Empty State OR Split-Pane Studio
            if (allNotes.isEmpty)
              Expanded(child: _buildEmptyState())
            else
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Notes Directory & Search
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier1,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          // Search Input
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceTier2,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                                      decoration: const InputDecoration(
                                        hintText: 'Search notes & specs...',
                                        hintStyle: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (v) => setState(() => _searchQuery = v),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(color: AppColors.borderSubtle, height: 1),

                          // Notes List
                          Expanded(
                            child: filteredNotes.isEmpty
                                ? Center(
                                    child: Text(
                                      'No matching notes',
                                      style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredNotes.length,
                                    itemBuilder: (context, idx) {
                                      final note = filteredNotes[idx];
                                      final isSelected = idx == _selectedNoteIndex;

                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedNoteIndex = idx;
                                            _currentlyEditingNoteId = null;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.surfaceHover : Colors.transparent,
                                            border: const Border(
                                              bottom: BorderSide(color: AppColors.borderSubtle),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.cyanBg,
                                                            borderRadius: BorderRadius.circular(3),
                                                          ),
                                                          child: Text(
                                                            note.category.toUpperCase(),
                                                            style: AppTypography.monoBadge.copyWith(fontSize: 8, color: AppColors.cyan),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      note.title,
                                                      style: AppTypography.bodyMedium.copyWith(
                                                        color: isSelected ? AppColors.cyan : AppColors.textHigh,
                                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.textSubtle),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                onPressed: () {
                                                  notesNotifier.deleteNote(note.id);
                                                  if (_selectedNoteIndex >= filteredNotes.length - 1 && _selectedNoteIndex > 0) {
                                                    setState(() => _selectedNoteIndex--);
                                                  }
                                                },
                                                tooltip: 'Delete note',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Right: Active Note Markdown Editor / Viewer
                    if (filteredNotes.isNotEmpty)
                      Expanded(
                        child: _buildEditorCanvas(filteredNotes[_selectedNoteIndex.clamp(0, filteredNotes.length - 1)]),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cyanBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 28, color: AppColors.cyan),
            ),
            const SizedBox(height: 16),
            Text('Knowledge Base is Clean', style: AppTypography.heading2.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Capture architecture decisions, algorithms, and design docs with zero distraction.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Text('CHOOSE A STARTER TEMPLATE', style: AppTypography.monoBadge.copyWith(fontSize: 10, color: AppColors.textSubtle)),
            const SizedBox(height: 12),

            // Starter Template 1
            _buildTemplateTile(
              title: 'System Architecture Specification',
              category: 'Architecture',
              subtitle: 'Components, data pipelines, caching tiers, and failure recovery.',
              markdown: '# System Architecture Specification\n\n## 1. High-Level Topology\n- Gateway: Envoy / Reverse Proxy\n- Compute: Stateless Go microservices\n- Storage: PostgreSQL 16 + Redis Cache\n\n## 2. Invariants & Guarantees\n- P99 Latency: < 25ms\n- Eventual Consistency Model: 100ms lag window\n\n## 3. Failure Scenarios\n- Primary database failover triggers automatic read-replica promotion.',
            ),
            const SizedBox(height: 8),

            // Starter Template 2
            _buildTemplateTile(
              title: 'Algorithm Pattern Study Sheet',
              category: 'Algorithms',
              subtitle: 'Monotonic stack, two pointers, sliding window, and graph BFS/DFS.',
              markdown: '# Algorithm Pattern: Monotonic Stack\n\n## Core Invariant\nStack maintains elements in strictly increasing or decreasing order.\n\n## Key LeetCode Problems\n- Next Greater Element I & II\n- Daily Temperatures\n- Largest Rectangle in Histogram\n\n## Complexity\n- Time: O(N) because each element is pushed and popped at most once.\n- Space: O(N) auxiliary stack.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateTile({
    required String title,
    required String category,
    required String subtitle,
    required String markdown,
  }) {
    return InkWell(
      onTap: () => _createNoteWithTemplate(title, category, markdown),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 16, color: AppColors.cyan),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorCanvas(KnowledgeNote note) {
    _syncControllers(note);

    final wordCount = _contentCtrl.text.trim().isEmpty ? 0 : _contentCtrl.text.trim().split(RegExp(r'\s+')).length;
    final charCount = _contentCtrl.text.length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editor Toolbar
          Row(
            children: [
              // Title Input
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  style: AppTypography.heading2.copyWith(fontSize: 20),
                  decoration: const InputDecoration(
                    hintText: 'Note Title...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => _saveCurrentNote(note),
                ),
              ),

              // Edit / Preview Toggle
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isPreviewMode = false),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: !_isPreviewMode ? AppColors.surfaceHover : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'EDIT',
                          style: AppTypography.monoBadge.copyWith(
                            fontSize: 10,
                            color: !_isPreviewMode ? AppColors.cyan : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isPreviewMode = true),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isPreviewMode ? AppColors.surfaceHover : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PREVIEW',
                          style: AppTypography.monoBadge.copyWith(
                            fontSize: 10,
                            color: _isPreviewMode ? AppColors.cyan : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Metadata Info Row
          Row(
            children: [
              Text('Category: ${note.category}', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(width: 14),
              Text('$wordCount words  |  $charCount characters', style: AppTypography.caption.copyWith(color: AppColors.textSubtle)),
            ],
          ),
          const Divider(color: AppColors.borderSubtle, height: 24),

          // Content Area
          Expanded(
            child: _isPreviewMode
                ? SingleChildScrollView(
                    child: SelectableText(
                      _contentCtrl.text,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textHigh,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  )
                : TextField(
                    controller: _contentCtrl,
                    maxLines: null,
                    expands: true,
                    style: AppTypography.monoCode.copyWith(
                      color: AppColors.textHigh,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Start writing in Markdown (# Heading, - List, ``` code)...',
                      hintStyle: TextStyle(color: AppColors.textSubtle),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => _saveCurrentNote(note),
                  ),
          ),
        ],
      ),
    );
  }
}
