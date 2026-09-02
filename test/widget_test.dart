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
import 'package:arete_os/presentation/providers/knowledge_provider.dart';
import 'package:arete_os/domain/models/knowledge_note.dart';
import 'package:arete_os/presentation/providers/resources_provider.dart';
import 'package:arete_os/presentation/providers/ai_coach_provider.dart';
import 'package:arete_os/presentation/providers/auth_provider.dart';
import 'package:arete_os/core/utils/natural_language_parser.dart';

void main() {
  testWidgets('AreteApp boots and displays Landing Page hero section',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: AreteApp()));
    await tester.pumpAndSettle();

    expect(find.text('ARETE OS'), findsWidgets);
    expect(find.text('GET STARTED FREE'), findsOneWidget);
    expect(find.text('EXPLORE LIVE DEMO'), findsOneWidget);
  });

  test('Auth Provider logs in user and provides personalized profile', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final success = await container.read(authProvider.notifier).login('dhyanesh@example.com', 'password123');
    expect(success, isTrue);

    final user = container.read(authProvider).user;
    expect(user, isNotNull);
    expect(user!.name, equals('Dhyanesh'));
    expect(user.email, equals('dhyanesh@example.com'));
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

  test('Peer Cohort tracks members and active focus sessions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cohortState = container.read(peerCohortProvider);
    expect(cohortState.cohort.members, isNotEmpty);
    expect(cohortState.cohort.name, contains('Cohort Alpha'));
  });

  test('Projects Notifier shifts tasks across Kanban columns', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final projects = container.read(projectsProvider);
    expect(projects, isNotEmpty);

    final project = projects.first;
    final task = project.tasks.first;

    container.read(projectsProvider.notifier).moveTask(project.id, task.id, ProjectColumn.inReview);

    final updatedProjects = container.read(projectsProvider);
    final updatedTask = updatedProjects.first.tasks.firstWhere((t) => t.id == task.id);
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

  test('Calendar Notifier toggles block completion', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final blocks = container.read(calendarProvider).blocks;
    expect(blocks, isNotEmpty);

    final block = blocks.first;
    container.read(calendarProvider.notifier).toggleBlockCompleted(block.id);

    final updated = container.read(calendarProvider).blocks.firstWhere((b) => b.id == block.id);
    expect(updated.isCompleted, equals(!block.isCompleted));
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

  test('Resources Notifier updates chapter units progress', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final resources = container.read(resourcesProvider);
    expect(resources, isNotEmpty);

    final res = resources.first;
    container.read(resourcesProvider.notifier).updateUnits(res.id, 55);

    final updated = container.read(resourcesProvider).firstWhere((r) => r.id == res.id);
    expect(updated.completedUnits, equals(55));
  });

  test('AI Coach generates retrospective synthesis report', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialReport = container.read(aiCoachProvider).latestReport;
    expect(initialReport, isNotNull);
    expect(initialReport!.deepWorkLoggedHours, greaterThan(0));
  });
}
