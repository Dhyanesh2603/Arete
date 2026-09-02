import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/learning_resource.dart';
import '../../providers/resources_provider.dart';

class ResourcesView extends ConsumerWidget {
  const ResourcesView({super.key});

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
                    Text('LEARNING RESOURCES & CURRICULUM', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Structured tracking for textbooks, courses, and seminal research papers.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${resources.length} Tracked Curricula',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.cyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resources Grid
            ...resources.map((res) {
              Color typeColor;
              Color typeBg;
              switch (res.type) {
                case ResourceType.course:
                  typeColor = AppColors.cyan;
                  typeBg = AppColors.cyanBg;
                  break;
                case ResourceType.book:
                  typeColor = AppColors.amber;
                  typeBg = AppColors.amberBg;
                  break;
                case ResourceType.researchPaper:
                  typeColor = AppColors.lavender;
                  typeBg = AppColors.lavenderBg;
                  break;
                case ResourceType.documentation:
                  typeColor = AppColors.mint;
                  typeBg = AppColors.mintBg;
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            res.type.name.toUpperCase(),
                            style: AppTypography.monoBadge.copyWith(color: typeColor, fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(res.authorOrPlatform, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                        const Spacer(),
                        Text(
                          '${res.completedUnits} / ${res.totalUnits} Units (${res.progressPercentage.toStringAsFixed(0)}%)',
                          style: AppTypography.monoBadge.copyWith(color: AppColors.mint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(res.title, style: AppTypography.heading2),
                    const SizedBox(height: 6),
                    Text(res.keyTakeaways, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: res.progressPercentage / 100.0,
                        backgroundColor: AppColors.surfaceTier2,
                        valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: () => notifier.updateUnits(res.id, res.completedUnits - 1),
                        ),
                        Text('Progress: ${res.completedUnits}', style: AppTypography.monoBadge),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.cyan),
                          onPressed: () => notifier.updateUnits(res.id, res.completedUnits + 1),
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
