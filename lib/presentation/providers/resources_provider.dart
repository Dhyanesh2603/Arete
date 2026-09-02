import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/learning_resource.dart';

class ResourcesNotifier extends StateNotifier<List<LearningResource>> {
  ResourcesNotifier() : super(_initialResources());

  static List<LearningResource> _initialResources() {
    return [
      const LearningResource(
        id: 'res-1',
        title: "Striver's A2Z DSA Course & Sheet",
        authorOrPlatform: 'takeuforward / Raj Vikramaditya',
        type: ResourceType.course,
        totalUnits: 455,
        completedUnits: 48,
        keyTakeaways: 'Complete pattern-based algorithmic mastery across 18 progressive steps.',
        externalUrl: 'https://takeuforward.org/strivers-a2z-dsa-course/strivers-a2z-dsa-course-sheet-2/',
      ),
      const LearningResource(
        id: 'res-2',
        title: 'Designing Data-Intensive Applications (DDIA)',
        authorOrPlatform: 'Martin Kleppmann (O’Reilly)',
        type: ResourceType.book,
        totalUnits: 12,
        completedUnits: 8,
        keyTakeaways: 'Transactions, Linearizability, Raft Consensus, Distributed Storage Engines.',
      ),
      const LearningResource(
        id: 'res-3',
        title: 'FlashAttention-2: Faster Attention with Better Parallelism and Work Partitioning',
        authorOrPlatform: 'Tri Dao et al. (Stanford AI)',
        type: ResourceType.researchPaper,
        totalUnits: 18,
        completedUnits: 14,
        keyTakeaways: 'Tiled SRAM memory IO reduction, forward and backward pass parallelization.',
      ),
      const LearningResource(
        id: 'res-4',
        title: 'Triton Language & Compiler Documentation',
        authorOrPlatform: 'OpenAI Triton Community',
        type: ResourceType.documentation,
        totalUnits: 25,
        completedUnits: 16,
        keyTakeaways: 'Python-like programming model for writing highly optimized custom GPU kernels.',
        externalUrl: 'https://triton-lang.org/',
      ),
    ];
  }

  void updateUnits(String id, int completed) {
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(completedUnits: completed.clamp(0, r.totalUnits));
      }
      return r;
    }).toList();
  }
}

final resourcesProvider =
    StateNotifierProvider<ResourcesNotifier, List<LearningResource>>((ref) {
  return ResourcesNotifier();
});
