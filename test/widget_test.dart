import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arete_os/main.dart';
import 'package:arete_os/presentation/providers/dsa_provider.dart';
import 'package:arete_os/domain/models/dsa_problem.dart';
import 'package:arete_os/presentation/providers/peer_cohort_provider.dart';

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
}
