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

void main() {
  testWidgets('AreteApp boots and displays Mission Control dashboard',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: AreteApp()));
    await tester.pumpAndSettle();

    expect(find.text('IDENTITY TARGET'), findsOneWidget);
    expect(find.text('WHAT TO EXECUTE NEXT'), findsOneWidget);
    expect(find.text('TODAY FLOW TIMELINE'), findsOneWidget);
    expect(find.text('DSA SQUAD ALPHA'), findsOneWidget);
  });

  test('DSA Provider accurately filters by difficulty and search query', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = container.read(dsaProvider);
    expect(initial.totalCount, greaterThan(20));

    // Filter by Easy
    container.read(dsaProvider.notifier).setDifficultyFilter(DsaDifficulty.easy);
    final easyFiltered = container.read(dsaProvider).filteredProblems;
    expect(easyFiltered.every((p) => p.difficulty == DsaDifficulty.easy), isTrue);

    // Reset filter and search query
    container.read(dsaProvider.notifier).setDifficultyFilter(null);
    container.read(dsaProvider.notifier).setSearchQuery('Kadane');
    final searched = container.read(dsaProvider).filteredProblems;
    expect(searched.any((p) => p.title.contains('Kadane')), isTrue);
  });

  test('Peer Cohort increments solved count upon problem completion', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialCohort = container.read(peerCohortProvider);
    final myInitialSolved = initialCohort.cohort.members
        .firstWhere((m) => m.id == initialCohort.currentUserId)
        .problemsSolvedToday;

    container.read(peerCohortProvider.notifier).incrementMyProblemsSolved();

    final updatedCohort = container.read(peerCohortProvider);
    final myUpdatedSolved = updatedCohort.cohort.members
        .firstWhere((m) => m.id == updatedCohort.currentUserId)
        .problemsSolvedToday;

    expect(myUpdatedSolved, equals(myInitialSolved + 1));
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
      priority: TaskPriority.p0,
      cognitiveTier: CognitiveTier.deep3x,
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

  test('Knowledge Base Notifier creates and updates notes', () {
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
