import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/project.dart';

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super(_initialProjects());

  static List<Project> _initialProjects() {
    return [
      Project(
        id: 'proj-1',
        title: 'FlashAttention-2 Triton GPU Kernel Implementation',
        goalTitle: 'Master Striver A2Z DSA Sheet & Land Staff Software Role',
        architectureMarkdown: '''
# Triton FlashAttention-2 Implementation Architecture
- Block tiling over SRAM Shared Memory banks (32 banks, 4 bytes/word).
- Online Softmax reduction to eliminate intermediate tensor writes to HBM.
- Multi-head query/key/value projection layout profiling using NVIDIA Nsight Compute.
''',
        deadline: DateTime.now().add(const Duration(days: 45)),
        tasks: [
          const ProjectTask(
            id: 'pt-1',
            projectId: 'proj-1',
            title: 'Implement 2D Tiled Matrix Multiplication in Triton',
            column: ProjectColumn.completed,
            priority: 'High',
            estimatedMinutes: 90,
            loggedMinutes: 90,
          ),
          const ProjectTask(
            id: 'pt-2',
            projectId: 'proj-1',
            title: 'Benchmark Shared Memory Bank Conflict Latencies',
            column: ProjectColumn.inProgress,
            priority: 'High',
            estimatedMinutes: 60,
            loggedMinutes: 25,
          ),
          const ProjectTask(
            id: 'pt-3',
            projectId: 'proj-1',
            title: 'Write Online Softmax Numerical Stability Tests',
            column: ProjectColumn.inReview,
            priority: 'Medium',
            estimatedMinutes: 45,
            loggedMinutes: 45,
          ),
          const ProjectTask(
            id: 'pt-4',
            projectId: 'proj-1',
            title: 'Profile Tensor Core Instruction Throughput with Nsight',
            column: ProjectColumn.backlog,
            priority: 'Low',
            estimatedMinutes: 60,
            loggedMinutes: 0,
          ),
        ],
      ),
      Project(
        id: 'proj-2',
        title: 'Distributed Key-Value Store with Raft Consensus',
        goalTitle: 'Ship Arete Web App',
        architectureMarkdown: '''
# Raft Distributed Consensus Engine
- Leader election state machine with randomized heartbeat timers.
- Log replication, commit index consensus, and persistent WAL state.
- Client linearizable read lease optimization.
''',
        deadline: DateTime.now().add(const Duration(days: 60)),
        tasks: [
          const ProjectTask(
            id: 'pt-5',
            projectId: 'proj-2',
            title: 'Build RPC Transport Layer over gRPC',
            column: ProjectColumn.completed,
            priority: 'Medium',
            estimatedMinutes: 60,
            loggedMinutes: 60,
          ),
          const ProjectTask(
            id: 'pt-6',
            projectId: 'proj-2',
            title: 'Implement Leader Election and Term Increment Logic',
            column: ProjectColumn.completed,
            priority: 'High',
            estimatedMinutes: 90,
            loggedMinutes: 90,
          ),
          const ProjectTask(
            id: 'pt-7',
            projectId: 'proj-2',
            title: 'Log Compaction and Snapshot Isolation Engine',
            column: ProjectColumn.inProgress,
            priority: 'High',
            estimatedMinutes: 120,
            loggedMinutes: 45,
          ),
          const ProjectTask(
            id: 'pt-8',
            projectId: 'proj-2',
            title: 'Chaos Monkey Network Partition Simulation Tests',
            column: ProjectColumn.backlog,
            priority: 'Low',
            estimatedMinutes: 60,
            loggedMinutes: 0,
          ),
        ],
      ),
    ];
  }

  void moveTask(String projectId, String taskId, ProjectColumn newColumn) {
    state = state.map((p) {
      if (p.id == projectId) {
        final updatedTasks = p.tasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(column: newColumn);
          }
          return t;
        }).toList();
        return p.copyWith(tasks: updatedTasks);
      }
      return p;
    }).toList();
  }

  void addTask(String projectId, ProjectTask task) {
    state = state.map((p) {
      if (p.id == projectId) {
        return p.copyWith(tasks: [...p.tasks, task]);
      }
      return p;
    }).toList();
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});
