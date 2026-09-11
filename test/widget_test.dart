import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arete_os/main.dart';
import 'package:arete_os/presentation/providers/dsa_provider.dart';
import 'package:arete_os/domain/models/dsa_problem.dart';
import 'package:arete_os/presentation/providers/peer_cohort_provider.dart';
import 'package:arete_os/presentation/providers/projects_provider.dart';
import 'package:arete_os/domain/models/project.dart';
import 'package:arete_os/presentation/providers/tasks_provider.dart';
import 'package:arete_os/domain/models/task.dart';
import 'package:arete_os/presentation/providers/calendar_provider.dart';
import 'package:arete_os/presentation/providers/goals_provider.dart';
import 'package:arete_os/domain/models/goal.dart';
import 'package:arete_os/presentation/providers/knowledge_provider.dart';
import 'package:arete_os/domain/models/knowledge_note.dart';
import 'package:arete_os/presentation/providers/resources_provider.dart';
import 'package:arete_os/presentation/providers/flight_plan_provider.dart';
import 'package:arete_os/presentation/providers/ai_coach_provider.dart';
import 'package:arete_os/presentation/providers/auth_provider.dart';
import 'package:arete_os/domain/models/calendar_event.dart';
import 'package:arete_os/domain/models/learning_resource.dart';
import 'package:arete_os/core/utils/natural_language_parser.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('Arete boots and displays Landing Page hero section',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: AreteApp()));
    await tester.pumpAndSettle();

    expect(find.text('ARETE'), findsWidgets);
    expect(find.text('GET STARTED FREE'), findsOneWidget);
    expect(find.text('SIGN IN'), findsWidgets);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  test('Auth Provider signs up new user with clean initial state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final success = await container.read(authProvider.notifier).signup('Dhyanesh', 'dhyanesh@example.com', 'pass123');
    expect(success, isTrue);

    final user = container.read(authProvider).user;
    expect(user, isNotNull);
    expect(user!.name, equals('Dhyanesh'));
    expect(user.totalProblemsSolved, equals(0));
    expect(user.totalFocusHours, equals(0.0));
  });

  test('Task Priorities are High (Red), Medium (Yellow), Low (Green)', () {
    expect(TaskPriority.high.label, equals('High'));
    expect(TaskPriority.high.color, equals(const Color(0xFFFB7185))); // Red

    expect(TaskPriority.medium.label, equals('Medium'));
    expect(TaskPriority.medium.color, equals(const Color(0xFFFBBF24))); // Yellow

    expect(TaskPriority.low.label, equals('Low'));
    expect(TaskPriority.low.color, equals(const Color(0xFF34D399))); // Green
  });

  test('Natural Language Task Parser parses High, Medium, Low priorities', () {
    final highParsed = NaturalLanguageTaskParser.parse('Solve Tree Max Path Sum tomorrow #dsa !high ~60m');
    expect(highParsed.title, contains('Solve Tree Max Path Sum'));
    expect(highParsed.priority, equals(TaskPriority.high));
    expect(highParsed.estimatedMinutes, equals(60));
    expect(highParsed.projectTag, equals('dsa'));
    expect(highParsed.dueDate, isNotNull);

    final lowParsed = NaturalLanguageTaskParser.parse('Read documentation #docs !low ~30m');
    expect(lowParsed.priority, equals(TaskPriority.low));
  });

  test('New User starts with 0 solved DSA problems', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dsaState = container.read(dsaProvider);
    expect(dsaState.problems, isNotEmpty);
    // Fresh user has 0 solved problems
    expect(dsaState.solvedCount, equals(0));
  });

  test('DSA Provider calculates Spaced Repetition (SM-2) intervals upon solving', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = container.read(dsaProvider);
    final todoProblem = initial.problems.firstWhere((p) => p.status == DsaStatus.todo);

    container.read(dsaProvider.notifier).toggleProblemStatus(todoProblem.id);

    final updated = container.read(dsaProvider).problems.firstWhere((p) => p.id == todoProblem.id);
    expect(updated.status, equals(DsaStatus.solved));
    expect(updated.nextRevisionDate, isNotNull);
    expect(updated.reviewCount, equals(1));
  });

  test('Peer Cohort tracks study squad members and invites peers by email', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialCohort = container.read(peerCohortProvider);
    expect(initialCohort.cohort.name, contains('Study Squad'));

    await container.read(peerCohortProvider.notifier).invitePeerByEmail('partner@example.com', name: 'Partner');
    final updated = container.read(peerCohortProvider);
    expect(updated.cohort.members.any((m) => m.email == 'partner@example.com'), isTrue);
    expect(updated.cohort.members.firstWhere((m) => m.email == 'partner@example.com').isInvited, isTrue);
  });

  test('Projects Notifier starts empty and shifts tasks across Kanban columns', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(projectsProvider), isEmpty);

    await container.read(projectsProvider.notifier).createProject(
          title: 'Test Project',
          goalTitle: 'Test Goal',
          architectureMarkdown: 'Architecture notes',
          deadline: DateTime.now().add(const Duration(days: 30)),
        );

    final project = container.read(projectsProvider).first;
    await container.read(projectsProvider.notifier).addProjectTask(
          project.id,
          ProjectTask(
            id: 'test-pt',
            projectId: project.id,
            title: 'Test Task',
            column: ProjectColumn.backlog,
          ),
        );

    await container.read(projectsProvider.notifier).moveTask(project.id, 'test-pt', ProjectColumn.inReview);

    final updatedProjects = container.read(projectsProvider);
    final updatedTask = updatedProjects.first.tasks.firstWhere((t) => t.id == 'test-pt');
    expect(updatedTask.column, equals(ProjectColumn.inReview));
  });

  test('Tasks Notifier adds and toggles task completion', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const newTask = Task(
      id: 'test-tk',
      title: 'Test New Task Creation',
      priority: TaskPriority.high,
    );

    container.read(tasksProvider.notifier).addTask(newTask);
    expect(container.read(tasksProvider).tasks.any((t) => t.id == 'test-tk'), isTrue);

    container.read(tasksProvider.notifier).toggleTask('test-tk');
    expect(container.read(tasksProvider).tasks.firstWhere((t) => t.id == 'test-tk').isCompleted, isTrue);
  });

  test('Calendar Notifier starts empty and adds blocks with completion toggle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(calendarProvider).blocks, isEmpty);

    final now = DateTime.now();
    container.read(calendarProvider.notifier).addBlock(
          title: 'Test Block',
          subtitle: 'Notes',
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
          type: CalendarBlockType.deepWork,
        );

    final blocks = container.read(calendarProvider).blocks;
    expect(blocks, hasLength(1));

    final block = blocks.first;
    container.read(calendarProvider.notifier).toggleBlockCompleted(block.id);

    final updated = container.read(calendarProvider).blocks.firstWhere((b) => b.id == block.id);
    expect(updated.isCompleted, isTrue);
  });

  test('Knowledge Base Notifier creates notes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final newNote = KnowledgeNote(
      id: 'test-note',
      title: 'Triton Kernel Architecture',
      contentMarkdown: '# Triton Notes',
      category: 'AI Systems',
      updatedAt: DateTime.now(),
    );

    container.read(knowledgeProvider.notifier).addNote(newNote);
    expect(container.read(knowledgeProvider).any((n) => n.id == 'test-note'), isTrue);
  });

  test('Resources Notifier starts empty and adds resource with chapter tracking', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(resourcesProvider), isEmpty);

    await container.read(resourcesProvider.notifier).addResource(
          const LearningResource(
            id: 'res-test',
            title: 'Test Course',
            authorOrPlatform: 'Test Platform',
            type: ResourceType.course,
            totalUnits: 100,
            completedUnits: 0,
            keyTakeaways: 'Notes',
          ),
        );

    await container.read(resourcesProvider.notifier).updateUnits('res-test', 25);

    final updated = container.read(resourcesProvider).firstWhere((r) => r.id == 'res-test');
    expect(updated.completedUnits, equals(25));
  });

  test('AI Coach starts empty and dynamically generates synthesis report on trigger', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(aiCoachProvider).latestReport, isNull);

    await container.read(aiCoachProvider.notifier).triggerSynthesis();

    final report = container.read(aiCoachProvider).latestReport;
    expect(report, isNotNull);
    expect(report!.assessment, isNotEmpty);
  });

  test('Adaptive Daily Flight Plan compiles sequential targets and handles completion', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final planState = container.read(flightPlanProvider);
    expect(planState.items, isNotEmpty);
    expect(planState.nextItem, isNotNull);
    expect(planState.totalEstimatedMinutes, greaterThan(0));

    final firstItem = planState.items.first;
    container.read(flightPlanProvider.notifier).toggleItemCompleted(firstItem.id);

    final updated = container.read(flightPlanProvider);
    expect(updated.completedCount, equals(1));
    expect(updated.completedIds.contains(firstItem.id), isTrue);
  });

  test('Tasks Notifier supports subtask checklist lifecycle', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const testTask = Task(id: 'task-sub-test', title: 'Parent Task');
    await container.read(tasksProvider.notifier).addTask(testTask);

    // 1. Add Subtask
    await container.read(tasksProvider.notifier).addSubtask('task-sub-test', 'Child Subtask 1');
    var task = container.read(tasksProvider).tasks.firstWhere((t) => t.id == 'task-sub-test');
    expect(task.subtaskItems.length, equals(1));
    expect(task.subtaskItems.first.title, equals('Child Subtask 1'));
    expect(task.subtaskItems.first.isCompleted, isFalse);

    // 2. Toggle Subtask Completion
    final subId = task.subtaskItems.first.id;
    await container.read(tasksProvider.notifier).toggleSubtask('task-sub-test', subId);
    task = container.read(tasksProvider).tasks.firstWhere((t) => t.id == 'task-sub-test');
    expect(task.subtaskItems.first.isCompleted, isTrue);

    // 3. Delete Subtask
    await container.read(tasksProvider.notifier).deleteSubtask('task-sub-test', subId);
    task = container.read(tasksProvider).tasks.firstWhere((t) => t.id == 'task-sub-test');
    expect(task.subtaskItems, isEmpty);
  });

  test('Goals Notifier manages milestones and dynamically updates weighted progress', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(goalsProvider.notifier).createGoal(
      identityTitle: 'Systems Architect',
      title: 'Master Distributed Systems',
      objectiveStatement: 'Build high-throughput event logs',
      targetDeadline: DateTime.now().add(const Duration(days: 60)),
      priority: GoalPriority.p0Critical,
    );

    final goal = container.read(goalsProvider).goals.first;
    expect(goal.weightedProgress, equals(0.0));

    // 1. Add 2 Milestones (Weight 1.0 and Weight 2.0 -> total 3.0)
    await container.read(goalsProvider.notifier).addMilestone(
      goalId: goal.id,
      title: 'Milestone 1',
      weightMultiplier: 1.0,
      deadline: DateTime.now().add(const Duration(days: 15)),
    );
    await container.read(goalsProvider.notifier).addMilestone(
      goalId: goal.id,
      title: 'Milestone 2',
      weightMultiplier: 2.0,
      deadline: DateTime.now().add(const Duration(days: 30)),
    );

    var milestones = container.read(goalsProvider).getMilestonesForGoal(goal.id);
    expect(milestones.length, equals(2));

    // 2. Toggle Milestone 2 (Weight 2.0 out of 3.0 = 66.7%)
    await container.read(goalsProvider.notifier).toggleMilestone(milestones[1].id);
    var updatedGoal = container.read(goalsProvider).goals.firstWhere((g) => g.id == goal.id);
    expect(updatedGoal.weightedProgress, equals(66.7));

    // 3. Toggle Milestone 1 (1.0 + 2.0 = 3.0 / 3.0 = 100%)
    await container.read(goalsProvider.notifier).toggleMilestone(milestones[0].id);
    updatedGoal = container.read(goalsProvider).goals.firstWhere((g) => g.id == goal.id);
    expect(updatedGoal.weightedProgress, equals(100.0));
  });

  test('Projects Notifier supports deleting tasks from Kanban board', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(projectsProvider.notifier).createProject(
      title: 'Compiler Project',
      goalTitle: 'Master Languages',
      architectureMarkdown: '# AST Specs',
      deadline: DateTime.now().add(const Duration(days: 30)),
    );

    final project = container.read(projectsProvider).first;
    const pTask = ProjectTask(
      id: 'pt-1',
      projectId: 'proj-temp',
      title: 'Write Lexer',
      column: ProjectColumn.backlog,
    );
    await container.read(projectsProvider.notifier).addProjectTask(project.id, pTask);

    var current = container.read(projectsProvider).firstWhere((p) => p.id == project.id);
    expect(current.tasks.length, equals(1));

    await container.read(projectsProvider.notifier).deleteProjectTask(project.id, 'pt-1');
    current = container.read(projectsProvider).firstWhere((p) => p.id == project.id);
    expect(current.tasks, isEmpty);
  });
}
