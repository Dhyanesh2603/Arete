import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/learning_resource.dart';
import '../../providers/resources_provider.dart';

class ResourcesView extends ConsumerWidget {
  const ResourcesView({super.key});

  void _showAddResourceDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final unitsCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    ResourceType selectedType = ResourceType.course;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderActive),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.cyanBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            size: 16, color: AppColors.cyan),
                      ),
                      const SizedBox(width: 10),
                      Text('Add Learning Resource',
                          style: AppTypography.heading2.copyWith(fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Resource Title',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TextField(
                      controller: titleCtrl,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Designing Data-Intensive Applications',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Author or Platform',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TextField(
                      controller: authorCtrl,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Martin Kleppmann',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Chapters / Units',
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.textMedium)),
                            const SizedBox(height: 6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceTier2,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: AppColors.borderSubtle),
                              ),
                              child: TextField(
                                controller: unitsCtrl,
                                keyboardType: TextInputType.number,
                                style: AppTypography.bodyMedium,
                                decoration: const InputDecoration(
                                  hintText: '10',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type',
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.textMedium)),
                            const SizedBox(height: 6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceTier2,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: AppColors.borderSubtle),
                              ),
                              child: DropdownButton<ResourceType>(
                                value: selectedType,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                dropdownColor: AppColors.surfaceTier2,
                                items: ResourceType.values.map((t) {
                                  return DropdownMenuItem(
                                    value: t,
                                    child: Text(t.name.toUpperCase(),
                                        style: AppTypography.caption),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedType = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Cancel',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;
                          final units = int.tryParse(unitsCtrl.text.trim()) ?? 10;

                          ref.read(resourcesProvider.notifier).addResource(
                                LearningResource(
                                  id: 'res-${DateTime.now().millisecondsSinceEpoch}',
                                  title: title,
                                  authorOrPlatform: authorCtrl.text.trim(),
                                  type: selectedType,
                                  totalUnits: units,
                                  completedUnits: 0,
                                  keyTakeaways: notesCtrl.text.trim(),
                                ),
                              );
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan),
                        child: Text(
                          'ADD RESOURCE',
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF0B0D13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(resourcesProvider);
    final notifier = ref.read(resourcesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEARNING RESOURCES & CURRICULUM',
                        style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Structured tracking for textbooks, courses, and seminal research papers.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddResourceDialog(context, ref),
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    'ADD RESOURCE',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF0B0D13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (resources.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Container(
                    width: 480,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book_outlined,
                            size: 42, color: AppColors.textSubtle),
                        const SizedBox(height: 14),
                        Text('No learning resources tracked',
                            style: AppTypography.heading2.copyWith(fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Add textbooks, documentation, video courses, or academic papers to track your chapter-by-chapter progression.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _showAddResourceDialog(context, ref),
                          icon: const Icon(Icons.add_rounded,
                              size: 16, color: Color(0xFF0B0D13)),
                          label: Text(
                            'ADD FIRST RESOURCE',
                            style: AppTypography.monoBadge.copyWith(
                              color: const Color(0xFF0B0D13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...resources.map((res) {
                final typeColor = switch (res.type) {
                  ResourceType.course => AppColors.cyan,
                  ResourceType.book => AppColors.lavender,
                  ResourceType.researchPaper => AppColors.rose,
                  ResourceType.documentation => AppColors.mint,
                };

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              res.type.name.toUpperCase(),
                              style: AppTypography.monoBadge
                                  .copyWith(color: typeColor, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              res.title,
                              style: AppTypography.heading2.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: AppColors.textSubtle),
                            onPressed: () {
                              notifier.deleteResource(res.id);
                            },
                            tooltip: 'Delete Resource',
                          ),
                        ],
                      ),
                      if (res.authorOrPlatform.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          res.authorOrPlatform,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: res.totalUnits == 0
                                    ? 0.0
                                    : res.completedUnits / res.totalUnits,
                                backgroundColor: AppColors.surfaceTier2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(typeColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${res.completedUnits} / ${res.totalUnits} Units',
                            style: AppTypography.monoBadge.copyWith(
                                color: AppColors.textHigh, fontSize: 11),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded,
                                size: 18, color: AppColors.textMuted),
                            onPressed: () => notifier.updateUnits(
                                res.id, res.completedUnits - 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                size: 18, color: AppColors.cyan),
                            onPressed: () => notifier.updateUnits(
                                res.id, res.completedUnits + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
