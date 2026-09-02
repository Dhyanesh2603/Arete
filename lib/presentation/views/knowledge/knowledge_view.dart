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

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(knowledgeProvider);
    final notesNotifier = ref.read(knowledgeProvider.notifier);

    if (notes.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: Text('No notes created.')),
      );
    }

    final activeNote = notes[_selectedNoteIndex.clamp(0, notes.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KNOWLEDGE BASE & ARCHITECTURE NOTES', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Distraction-free markdown repository linking concepts, algorithms, and architectures.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    final newNote = KnowledgeNote(
                      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
                      title: 'New Technical Architecture Note',
                      contentMarkdown: '# New Architecture Note\n\nStart writing markdown specifications here...',
                      category: 'Engineering',
                      updatedAt: DateTime.now(),
                    );
                    notesNotifier.addNote(newNote);
                  },
                  icon: const Icon(Icons.add, size: 16, color: AppColors.cyan),
                  label: Text('New Note', style: AppTypography.monoBadge.copyWith(color: AppColors.cyan)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Notes List
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, idx) {
                        final note = notes[idx];
                        final isSelected = idx == _selectedNoteIndex;

                        return InkWell(
                          onTap: () => setState(() => _selectedNoteIndex = idx),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceHover : Colors.transparent,
                              border: const Border(
                                bottom: BorderSide(color: AppColors.borderSubtle),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyanBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        note.category,
                                        style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.cyan),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  note.title,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: isSelected ? AppColors.cyan : AppColors.textHigh,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  children: note.tags.map((tag) {
                                    return Text('#$tag', style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10));
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right: Markdown Canvas Editor / Preview
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier1,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activeNote.title, style: AppTypography.heading1),
                            const SizedBox(height: 6),
                            Text(
                              'Category: ${activeNote.category}  |  Updated: ${activeNote.updatedAt.hour}:${activeNote.updatedAt.minute}',
                              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 32),
                            SelectableText(
                              activeNote.contentMarkdown,
                              style: AppTypography.monoCode.copyWith(
                                color: AppColors.textHigh,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
