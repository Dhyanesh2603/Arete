import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/dsa_problem.dart';
import '../../providers/dsa_provider.dart';

class MockInterviewView extends ConsumerStatefulWidget {
  const MockInterviewView({super.key});

  @override
  ConsumerState<MockInterviewView> createState() => _MockInterviewViewState();
}

class _MockInterviewViewState extends ConsumerState<MockInterviewView> {
  Timer? _timer;
  int _secondsRemaining = 45 * 60; // 45 minutes
  bool _isFinished = false;
  int _activeProblemIndex = 0;
  List<DsaProblem> _interviewProblems = [];
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _complexityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProblems();
      _startTimer();
    });
  }

  void _initProblems() {
    final dsaState = ref.read(dsaProvider);
    final mediumProblems = dsaState.problems.where((p) => p.difficulty == DsaDifficulty.medium).toList();
    final hardProblems = dsaState.problems.where((p) => p.difficulty == DsaDifficulty.hard).toList();

    mediumProblems.shuffle();
    hardProblems.shuffle();

    setState(() {
      _interviewProblems = [
        if (mediumProblems.isNotEmpty) mediumProblems.first,
        if (hardProblems.isNotEmpty) hardProblems.first,
      ];
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _isFinished = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _complexityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final timeFormatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar with Timer & Exit
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('45-MINUTE TECHNICAL MOCK INTERVIEW', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Live simulation with randomized Medium + Hard algorithmic challenges.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _secondsRemaining < 300 ? AppColors.rose : AppColors.cyan,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: _secondsRemaining < 300 ? AppColors.rose : AppColors.cyan),
                      const SizedBox(width: 8),
                      Text(
                        timeFormatted,
                        style: AppTypography.monoTimer.copyWith(
                          fontSize: 20,
                          color: _secondsRemaining < 300 ? AppColors.rose : AppColors.textHigh,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isFinished = true);
                    _timer?.cancel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('SUBMIT INTERVIEW', style: AppTypography.monoBadge.copyWith(color: const Color(0xFF0B0D13), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => context.go('/dsa'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isFinished)
              _buildEvaluationSummary()
            else if (_interviewProblems.isNotEmpty)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Problem Tabs & Problem Statement
                    Container(
                      width: 440,
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
                            children: _interviewProblems.asMap().entries.map((e) {
                              final idx = e.key;
                              final prob = e.value;
                              final isSelected = idx == _activeProblemIndex;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => setState(() => _activeProblemIndex = idx),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.surfaceHover : AppColors.surfaceTier2,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isSelected ? AppColors.cyan : AppColors.borderSubtle),
                                    ),
                                    child: Text(
                                      'Problem ${idx + 1} (${prob.difficulty.name.toUpperCase()})',
                                      style: AppTypography.monoBadge.copyWith(
                                        color: isSelected ? AppColors.cyan : AppColors.textMedium,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(_interviewProblems[_activeProblemIndex].title, style: AppTypography.heading2),
                          const SizedBox(height: 6),
                          Text(
                            'Step: ${_interviewProblems[_activeProblemIndex].stepTitle}  |  Sub-Topic: ${_interviewProblems[_activeProblemIndex].subTopic}',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                          const Divider(color: AppColors.borderSubtle, height: 28),
                          Text('Pattern Signature:', style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(_interviewProblems[_activeProblemIndex].pattern, style: AppTypography.bodyMedium),
                          const SizedBox(height: 20),
                          Text('Instructions:', style: AppTypography.monoBadge.copyWith(color: AppColors.amber, fontSize: 10)),
                          const SizedBox(height: 6),
                          Text(
                            '1. Analyze time and space complexity constraints.\n2. Write clean pseudocode / implementation.\n3. Verify edge cases before submitting.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Right Column: Code Scratchpad & Complexity
                    Expanded(
                      child: Container(
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
                                Text('ALGORITHMIC SCRATCHPAD', style: AppTypography.heading2),
                                const Spacer(),
                                Container(
                                  width: 240,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceTier2,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: TextField(
                                    controller: _complexityController,
                                    style: AppTypography.monoBadge.copyWith(color: AppColors.cyan),
                                    decoration: const InputDecoration(
                                      hintText: 'Complexity: O(N log N) Time, O(1) Space',
                                      hintStyle: TextStyle(fontSize: 10, color: AppColors.textSubtle),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF08090E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: TextField(
                                  controller: _codeController,
                                  maxLines: null,
                                  expands: true,
                                  style: AppTypography.monoCode.copyWith(fontSize: 13, height: 1.5),
                                  decoration: const InputDecoration(
                                    hintText: '// Write your optimal approach and clean code here...\nclass Solution {\npublic:\n    \n};',
                                    hintStyle: TextStyle(color: AppColors.textSubtle),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildEvaluationSummary() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 28, color: AppColors.mint),
              const SizedBox(width: 12),
              Text('MOCK TECHNICAL INTERVIEW COMPLETED', style: AppTypography.heading1),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Time Used: ${(45 * 60 - _secondsRemaining) ~/ 60}m ${_secondsRemaining % 60}s  |  Problems Attempted: 2 / 2',
            style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            'Both problems have been recorded in your practice log and queued for Spaced Repetition review in 24 hours.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/dsa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text('RETURN TO DSA ROADMAP', style: AppTypography.monoBadge.copyWith(color: const Color(0xFF0B0D13), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
